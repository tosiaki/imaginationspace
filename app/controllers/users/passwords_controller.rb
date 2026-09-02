# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  RECOVERY_RATE_LIMIT_STORE = ActiveSupport::Cache::MemoryStore.new(size: 1.megabyte)

  layout "authentication"

  rate_limit to: 5, within: 30.minutes, only: :create, store: RECOVERY_RATE_LIMIT_STORE
  after_action :prevent_authentication_response_caching

  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  protected

  # def after_resetting_password_path_for(resource)
  #   super
  # end

  # The path used after sending reset password instructions
  def after_sending_reset_password_instructions_path_for(resource_name)
    login_path
  end

  private

  def prevent_authentication_response_caching
    response.headers["Cache-Control"] = "no-store"
  end
end
