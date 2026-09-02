#!/usr/bin/env ruby

require "aws-sdk-s3"
require "json"
require "time"

ids = ARGV.map { |argument| Integer(argument, 10) }.uniq.sort
abort "usage: bundle exec ruby script/audit_s3_picture_ids.rb ID [ID ...]" if ids.empty?

client = Aws::S3::Client.new(
  region: ENV.fetch("S3_REGION"),
  access_key_id: ENV.fetch("S3_ACCESS_KEY"),
  secret_access_key: ENV.fetch("S3_SECRET_KEY")
)
bucket = ENV.fetch("S3_BUCKET")

all_objects = []
client.list_objects_v2(bucket: bucket).each_page do |page|
  page.contents.each { |object| all_objects << object }
end

objects_by_signature = all_objects.group_by do |object|
  [object.size, object.etag.delete('"')]
end

target_objects = all_objects.select do |object|
  ids.any? { |id| object.key.start_with?("is/picture/#{id}/") }
end

rows = target_objects.sort_by(&:key).map do |object|
  signature = [object.size, object.etag.delete('"')]
  exact_matches = objects_by_signature.fetch(signature).reject do |match|
    match.key == object.key
  end

  {
    key: object.key,
    size: object.size,
    etag: object.etag.delete('"'),
    modified: object.last_modified.utc.iso8601(6),
    exact_matches: exact_matches.map(&:key).sort
  }
end

puts JSON.pretty_generate(
  bucket_object_count: all_objects.length,
  target_record_ids: ids,
  target_object_count: rows.length,
  target_bytes: rows.sum { |row| row.fetch(:size) },
  objects: rows
)
