#!/usr/bin/env ruby

require "aws-sdk-s3"
require "digest"
require "fileutils"
require "json"
require "time"

mode, archive_dir, expected_manifest_sha = ARGV
unless %w[archive delete].include?(mode) && archive_dir
  abort "usage: bundle exec ruby script/archive_s3_prefix.rb archive|delete ARCHIVE_DIR [EXPECTED_MANIFEST_SHA256]"
end

bucket = ENV.fetch("S3_BUCKET")
prefix = ENV.fetch("S3_ARCHIVE_PREFIX", "is_cache/")
excluded_prefix = ENV.fetch("S3_ARCHIVE_EXCLUDED_PREFIX", "is_cache/uploads/")
client = Aws::S3::Client.new(
  region: ENV.fetch("S3_REGION"),
  access_key_id: ENV.fetch("S3_ACCESS_KEY"),
  secret_access_key: ENV.fetch("S3_SECRET_KEY")
)

def list_objects(client, bucket, prefix, excluded_prefix)
  objects = []
  client.list_objects_v2(bucket: bucket, prefix: prefix).each_page do |page|
    page.contents.each do |object|
      next if object.key.start_with?(excluded_prefix)

      objects << {
        "key" => object.key,
        "size" => object.size,
        "etag" => object.etag.delete('"'),
        "last_modified" => object.last_modified.utc.iso8601(6),
        "storage_class" => object.storage_class
      }
    end
  end
  objects.sort_by { |object| object.fetch("key").b }
end

def manifest_bytes(manifest)
  JSON.pretty_generate(manifest) + "\n"
end

FileUtils.mkdir_p(archive_dir)
manifest_path = File.join(archive_dir, "manifest.json")
blobs_dir = File.join(archive_dir, "blobs")

case mode
when "archive"
  abort "archive already has a manifest: #{manifest_path}" if File.exist?(manifest_path)

  FileUtils.mkdir_p(blobs_dir)
  objects = list_objects(client, bucket, prefix, excluded_prefix)
  abort "no objects found under #{prefix.inspect}" if objects.empty?

  objects.each_with_index do |object, index|
    digest = Digest::SHA256.new
    temporary_path = File.join(archive_dir, ".download-#{Process.pid}")
    File.open(temporary_path, "wb") do |file|
      client.get_object(bucket: bucket, key: object.fetch("key")) do |chunk|
        file.write(chunk)
        digest.update(chunk)
      end
    end

    actual_size = File.size(temporary_path)
    abort "size mismatch for #{object.fetch('key')}" unless actual_size == object.fetch("size")

    sha256 = digest.hexdigest
    blob_path = File.join(blobs_dir, sha256)
    if File.exist?(blob_path)
      abort "existing blob size mismatch for #{sha256}" unless File.size(blob_path) == actual_size
      abort "existing blob digest mismatch for #{sha256}" unless Digest::SHA256.file(blob_path).hexdigest == sha256
      File.delete(temporary_path)
    else
      File.rename(temporary_path, blob_path)
    end
    object["sha256"] = sha256
    object["blob"] = "blobs/#{sha256}"
    warn "archived #{index + 1}/#{objects.length}" if ((index + 1) % 25).zero? || index + 1 == objects.length
  ensure
    File.delete(temporary_path) if temporary_path && File.exist?(temporary_path)
  end

  manifest = {
    "format" => 1,
    "bucket" => bucket,
    "prefix" => prefix,
    "excluded_prefix" => excluded_prefix,
    "archived_at" => Time.now.utc.iso8601(6),
    "object_count" => objects.length,
    "total_bytes" => objects.sum { |object| object.fetch("size") },
    "unique_blob_count" => objects.map { |object| object.fetch("sha256") }.uniq.length,
    "objects" => objects
  }
  bytes = manifest_bytes(manifest)
  File.write(manifest_path, bytes, mode: "wb")
  puts JSON.generate(
    manifest: manifest_path,
    manifest_sha256: Digest::SHA256.hexdigest(bytes),
    object_count: manifest.fetch("object_count"),
    total_bytes: manifest.fetch("total_bytes"),
    unique_blob_count: manifest.fetch("unique_blob_count")
  )
when "delete"
  abort "EXPECTED_MANIFEST_SHA256 is required for delete" unless expected_manifest_sha
  abort "manifest not found: #{manifest_path}" unless File.file?(manifest_path)

  bytes = File.binread(manifest_path)
  actual_manifest_sha = Digest::SHA256.hexdigest(bytes)
  abort "manifest digest mismatch" unless actual_manifest_sha == expected_manifest_sha

  manifest = JSON.parse(bytes)
  abort "bucket mismatch" unless manifest.fetch("bucket") == bucket
  abort "prefix mismatch" unless manifest.fetch("prefix") == prefix
  abort "excluded prefix mismatch" unless manifest.fetch("excluded_prefix") == excluded_prefix

  archived_objects = manifest.fetch("objects")
  current_objects = list_objects(client, bucket, prefix, excluded_prefix)
  current_projection = current_objects.map { |object| object.slice("key", "size", "etag", "last_modified", "storage_class") }
  archived_projection = archived_objects.map { |object| object.slice("key", "size", "etag", "last_modified", "storage_class") }
  abort "S3 inventory changed since archival; refusing deletion" unless current_projection == archived_projection

  archived_objects.each do |object|
    blob_path = File.join(archive_dir, object.fetch("blob"))
    abort "missing archived blob for #{object.fetch('key')}" unless File.file?(blob_path)
    abort "archived blob size mismatch for #{object.fetch('key')}" unless File.size(blob_path) == object.fetch("size")
    abort "archived blob digest mismatch for #{object.fetch('key')}" unless Digest::SHA256.file(blob_path).hexdigest == object.fetch("sha256")
  end

  archived_objects.each_slice(1_000) do |batch|
    response = client.delete_objects(
      bucket: bucket,
      delete: { objects: batch.map { |object| { key: object.fetch("key") } }, quiet: false }
    )
    abort "S3 deletion errors: #{response.errors.map(&:to_h).to_json}" unless response.errors.empty?
  end

  remaining_keys = list_objects(client, bucket, prefix, excluded_prefix).map { |object| object.fetch("key") }
  deleted_keys = archived_objects.map { |object| object.fetch("key") }
  survivors = remaining_keys & deleted_keys
  abort "#{survivors.length} archived keys still exist after deletion" unless survivors.empty?

  puts JSON.generate(deleted_object_count: deleted_keys.length, deleted_bytes: manifest.fetch("total_bytes"), remaining_legacy_objects: remaining_keys.length)
end
