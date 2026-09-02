class UploadSmokeTestsController < ApplicationController
  before_action :prevent_private_response_caching
  before_action :require_authenticated_user!
  after_action :prevent_private_response_caching

  layout "authentication"

  def new
  end

  def create
    key = params.require(:key)
    size = Integer(params.require(:size).to_s, 10)
    authorize_upload!(key, size, params.require(:authorization))
    uploaded_size = uploaded_object_size(key)
    raise InvalidUpload, "Uploaded object size did not match" unless uploaded_size == size

    upload_storage.delete(key)
    render json: { status: "verified_and_deleted", key: key, size: size }
  rescue ActionController::ParameterMissing, ArgumentError,
    ActiveSupport::MessageVerifier::InvalidSignature, InvalidUpload => error
    render json: { error: error.message }, status: :unprocessable_content
  end

  private

  class InvalidUpload < StandardError; end

  def authorize_upload!(key, size, authorization)
    payload = Rails.application.message_verifier(:direct_upload_authorization)
      .verify(authorization)
      .with_indifferent_access

    valid = DirectUploadSigner::KEY_PATTERN.match?(key) &&
      size.between?(1, DirectUploadSigner::MAXIMUM_FILE_SIZE) &&
      payload[:user_id] == current_user.id &&
      payload[:key] == key &&
      payload[:size] == size
    raise InvalidUpload, "Invalid or expired upload authorization" unless valid
  end

  def uploaded_object_size(key)
    object = upload_storage.open(key)
    object.size
  rescue Shrine::FileNotFound
    raise InvalidUpload, "Uploaded object was not found"
  ensure
    object&.close
  end

  def upload_storage
    Shrine.storages.fetch(:cache)
  end
end
