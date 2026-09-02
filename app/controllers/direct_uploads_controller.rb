class DirectUploadsController < ApplicationController
  SIGNING_RATE_LIMIT_STORE = ActiveSupport::Cache::MemoryStore.new(size: 1.megabyte)

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  rate_limit to: 30, within: 10.minutes, only: :create, store: SIGNING_RATE_LIMIT_STORE

  rescue_from DirectUploadSigner::InvalidRequest, with: :render_invalid_request

  def create
    size = upload_size
    key = params.require(:key)
    result = upload_signer.call(
      method: params.require(:method),
      key: key,
      size: size
    )
    result[:authorization] = upload_authorization_verifier.generate(
      { user_id: current_user.id, key: key, size: size },
      expires_in: DirectUploadSigner::URL_LIFETIME
    )
    response.headers["Cache-Control"] = "no-store"
    render json: result
  end

  private

  def upload_signer
    DirectUploadSigner.new
  end

  def upload_size
    Integer(params.require(:size).to_s, 10)
  rescue ArgumentError
    raise DirectUploadSigner::InvalidRequest, "Invalid file size"
  end

  def render_invalid_request(error)
    render json: { error: error.message }, status: :unprocessable_entity
  end

  def upload_authorization_verifier
    Rails.application.message_verifier(:direct_upload_authorization)
  end
end
