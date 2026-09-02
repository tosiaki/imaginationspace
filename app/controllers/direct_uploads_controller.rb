class DirectUploadsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  rescue_from DirectUploadSigner::InvalidRequest, with: :render_invalid_request

  def create
    render json: DirectUploadSigner.new.call(
      method: params.require(:method),
      key: params.require(:key),
      size: params.require(:size)
    )
  end

  private

  def render_invalid_request(error)
    render json: { error: error.message }, status: :unprocessable_entity
  end
end
