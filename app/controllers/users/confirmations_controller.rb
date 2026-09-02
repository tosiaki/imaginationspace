# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  CONFIRMATION_RATE_LIMIT_STORE = ActiveSupport::Cache::MemoryStore.new(size: 1.megabyte)

  layout "authentication"

  rate_limit to: 5, within: 30.minutes, only: :create, store: CONFIRMATION_RATE_LIMIT_STORE
  after_action :prevent_authentication_response_caching

  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  # def show
  #   super
  # end

  protected

  # The path used after resending confirmation instructions.
  def after_resending_confirmation_instructions_path_for(resource_name)
    login_path
  end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end

  private

  def prevent_authentication_response_caching
    response.headers["Cache-Control"] = "no-store"
  end
end
