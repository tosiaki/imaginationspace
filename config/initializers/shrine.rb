require 'shrine'
require 'shrine/storage/file_system'
require 'shrine/storage/s3'

if Rails.env.development? || Rails.env.production? || Rails.env.transfer?
  s3_options = {
    bucket: ENV['S3_BUCKET'],
    access_key_id: ENV['S3_ACCESS_KEY'],
    secret_access_key: ENV['S3_SECRET_KEY'],
    region: ENV['S3_REGION']
  }
end

if Rails.env.development?
  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: "development_cache", **s3_options),
    store: Shrine::Storage::S3.new(prefix: "development_store", public: true, **s3_options),
    # new_store: Shrine::Storage::S3.new(prefix: "new_development_store", public: true, **s3_options)
  }
  # Shrine.plugin :default_storage, store: :store
end

if Rails.env.transfer?
  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: "legacy_cache", **s3_options),
    store: Shrine::Storage::S3.new(prefix: "legacy", public: true, **s3_options),
    # new_store: Shrine::Storage::S3.new(prefix: "new_legacy", public: true, **s3_options)
  }
  # Shrine.plugin :default_storage, store: :store
end

if Rails.env.production?
  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: "is_cache", **s3_options),
    store: Shrine::Storage::S3.new(prefix: "is", public: true, **s3_options)
  }
end

if Rails.env.test?
  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new('public', prefix: 'uploads/cache'),
    store: Shrine::Storage::FileSystem.new('public', prefix: 'uploads/store')
  }
end

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data
# Shrine.plugin :backgrounding
Shrine.plugin :presign_endpoint, presign_options: -> (request) {
  filename = request.params["filename"]
  type = request.params["type"]

  {
    content_disposition: ContentDisposition.inline(filename),
    content_type: type,
    content_length_range:   0..(1024*1024*1024),
  }
}
# Shrine::Attacher.promote { |data| PromoteJob.perform_later(data) }