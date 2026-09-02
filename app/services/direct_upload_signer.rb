class DirectUploadSigner
  MAXIMUM_FILE_SIZE = 1.gigabyte
  KEY_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}(?:\.[a-z0-9]{1,10})?\z/
  URL_LIFETIME = 15.minutes

  class InvalidRequest < StandardError; end

  def initialize(storage: Shrine.storages.fetch(:cache))
    @storage = storage
  end

  def call(method:, key:, size:)
    raise InvalidRequest, "Only single-part uploads are supported" unless method == "PUT"
    raise InvalidRequest, "Invalid upload key" unless KEY_PATTERN.match?(key)
    raise InvalidRequest, "Invalid file size" unless size.is_a?(Integer) && size.between?(1, MAXIMUM_FILE_SIZE)
    raise InvalidRequest, "Upload storage is unavailable" unless @storage.respond_to?(:presign)

    # Signing Content-Length binds the claimed size to the S3 request. S3 will
    # reject a client that tries to upload more data than was authorized.
    presign = @storage.presign(
      key,
      method: :put,
      expires_in: URL_LIFETIME.to_i,
      content_length: size
    )
    { url: presign.fetch(:url) }
  end
end
