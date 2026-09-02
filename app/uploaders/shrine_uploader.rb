require "image_processing/mini_magick"

class ShrineUploader < Shrine
  ALLOWED_MIME_TYPES = %w[image/gif image/jpeg image/png image/webp].freeze

  plugin :determine_mime_type, analyzer: :marcel
  plugin :validation_helpers
  plugin :refresh_metadata
  plugin :derivatives, create_on_promote: true, versions_compatibility: true
  plugin :store_dimensions

  Attacher.validate do
    validate_mime_type_inclusion ALLOWED_MIME_TYPES
    validate_max_size DirectUploadSigner::MAXIMUM_FILE_SIZE
  end

  plugin :upload_options, store: -> (io, context) do
    io.is_a?(Shrine::UploadedFile) ? { metadata_directive: "REPLACE" } : {}
  end

  Attacher.derivatives do |original|
    pipeline = ImageProcessing::MiniMagick.source(original)

    {
      show_page: pipeline.resize_to_limit!(1200, 2000),
      thumb: pipeline.resize_to_limit!(200, 200)
    }
  end

  class Attacher
    def promote(**options)
      refresh_metadata!
      super
    end
  end

  def generate_location(io, context)
    original_filename = context[:record]&.picture&.original_filename || context[:metadata]["filename"]
    derivative_suffix = "_#{context[:derivative]}" if context[:derivative]
    basename          = File.basename(original_filename, ".*")
    extension         = File.extname(original_filename).downcase

    "picture/#{context[:record].id}/#{basename}#{derivative_suffix}#{extension}"
  end

  # Attacher.promote { |data| PromoteWorker.perform_later(data) }
end
