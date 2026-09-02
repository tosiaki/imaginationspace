class DirectUploadsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  rescue_from DirectUploadSigner::InvalidRequest, with: :render_invalid_request

  def create
    render json: upload_signer.call(
      method: params.require(:method),
      key: params.require(:key),
      size: upload_size
    )
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
end
