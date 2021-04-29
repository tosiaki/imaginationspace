require "image_processing/mini_magick"

class ShrineUploader < Shrine
  plugin :refresh_metadata
  plugin :processing
  plugin :versions
  plugin :store_dimensions

  plugin :upload_options, store: -> (io, context) do
    io.is_a?(Shrine::UploadedFile) ? { metadata_directive: "REPLACE" } : {}
  end

  process(:store) do |io, context|
    io.refresh_metadata!(context)

    versions = { original: io } # retain original

    io.download do |original|
      pipeline = ImageProcessing::MiniMagick.source(original)

      versions[:show_page]  = pipeline.resize_to_limit!(1200, 2000)
      versions[:thumb] = pipeline.resize_to_limit!(200, 200)
    end

    versions # return the hash of processed files
  end

  def generate_location(io, context)
    debugger
    original_filename = context[:record]&.picture&.original_filename || context[:metadata]["filename"]
    version_suffix    = "_#{context[:version]}" if context[:version] && context[:version] != :original
    basename          = File.basename(original_filename, ".*")
    extension         = File.extname(original_filename).downcase

    "picture/#{context[:record].id}/#{basename}#{version_suffix}#{extension}"
  end

  # Attacher.promote { |data| PromoteWorker.perform_later(data) }
end
