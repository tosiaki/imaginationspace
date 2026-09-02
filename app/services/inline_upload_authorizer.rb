class InlineUploadAuthorizer
  ALLOWED_MIME_TYPES = %w[image/gif image/jpeg image/png image/webp].freeze

  class InvalidUpload < StandardError; end

  def initialize(user:, verifier: Rails.application.message_verifier(:direct_upload_authorization))
    @user = user
    @verifier = verifier
  end

  def call(content)
    fragment = Nokogiri::HTML.fragment(content.to_s)
    fragment.css("img[data-file-data]").each { |image| authorize!(image) }
    unformatted = Nokogiri::XML::Node::SaveOptions.class_eval { |options| options::DEFAULT_HTML ^ options::FORMAT }
    fragment.to_html(save_with: unformatted)
  rescue JSON::ParserError, ActiveSupport::MessageVerifier::InvalidSignature, KeyError, TypeError
    raise InvalidUpload, "Invalid or expired upload authorization"
  end

  private

  def authorize!(image)
    data = JSON.parse(image["data-file-data"])
    metadata = data.fetch("metadata")
    authorization = metadata.delete("upload_authorization")
    payload = @verifier.verify(authorization).with_indifferent_access

    key = data.fetch("id")
    size = Integer(metadata.fetch("size"))
    mime_type = metadata.fetch("mime_type")
    filename = metadata.fetch("filename")

    valid = data.fetch("storage") == "cache" &&
      DirectUploadSigner::KEY_PATTERN.match?(key) &&
      size.between?(1, DirectUploadSigner::MAXIMUM_FILE_SIZE) &&
      ALLOWED_MIME_TYPES.include?(mime_type) &&
      filename.is_a?(String) && filename.bytesize.between?(1, 255) &&
      payload[:user_id] == @user.id && payload[:key] == key && payload[:size] == size
    raise InvalidUpload, "Invalid or expired upload authorization" unless valid

    image["data-file-data"] = JSON.generate(data)
  end
end
