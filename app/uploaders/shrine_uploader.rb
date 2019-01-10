require "image_processing/mini_magick"

class ShrineUploader < Shrine
  plugin :pretty_location
  plugin :refresh_metadata
  plugin :processing
  plugin :versions
  plugin :store_dimensions

  plugin :upload_options, store: -> (io, context) do
    { metadata_directive: "REPLACE" } if io.is_a?(Shrine::UploadedFile)
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

  # Attacher.promote { |data| PromoteWorker.perform_later(data) }
end