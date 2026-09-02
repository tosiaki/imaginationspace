# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  LOGIN_RATE_LIMIT_STORE = ActiveSupport::Cache::MemoryStore.new(size: 1.megabyte)

  layout "authentication"

  rate_limit to: 10, within: 5.minutes, only: :create, store: LOGIN_RATE_LIMIT_STORE
  after_action :prevent_authentication_response_caching

  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/login
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  private

  def prevent_authentication_response_caching
    response.headers["Cache-Control"] = "no-store"
  end
end
