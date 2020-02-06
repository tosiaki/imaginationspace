# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /register
  # def new
  #   @user = User.new
  # end

  # POST /resource
  def create
		if @guest_user
			self.resource = @guest_user
			if resource.update_attributes(user_params)
				Devise::Mailer.confirmation_instructions(resource).deliver_later
				set_flash_message! :notice,
					:"signed_up_but_#{resource.inactive_message}"
				expire_data_after_sign_in!
				respond_with resource, location: after_inactive_sign_up_path_for(
					resource)
			else
				build_resource(sign_up_params)
				resource.save
				clean_up_passwords resource
				set_minimum_password_length
				respond_with resource
			end
		else
			super
		end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
	
	private
		def user_params
			params.require(:user).permit(:email, :name, :password,
																	 :password_confirmation, :site_updates)
		end
end
