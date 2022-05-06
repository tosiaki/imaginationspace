class ApplicationController < ActionController::Base
  protect_from_forgery unless: -> { request.format.json? }

  before_action :store_user_location!, if: :storable_location?
  before_action :configure_permitted_parameters, if: :devise_controller?

	# before_action :create_guest_user, unless: :has_user?

  def record_activity(activity_type, details)
    UserActivity.create(user: current_user, activity_type: activity_type, details: details)
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :site_updates])
    end


  private

    def storable_location?
      request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
    end

    def store_user_location!
      store_location_for(:user, request.fullpath)
    end

    def after_sign_out_path_for(resource_or_scope)
      stored_location_for(resource_or_scope) || request.referrer || super
    end

		def has_user?
			if user_signed_in?
				current_user
			else
				user = User.find_by(id: cookies.signed[:guest_user_id], guest: true)
				if user && user.valid_password?(cookies.signed[:guest_password])
					@guest_user = user
				else
					nil
				end
			end
		end

		def create_guest_user
			guest_name = "guest_#{Time.now.to_i}#{rand(100)}"
			guest_password = rand(100)
			guest_email = "#{guest_name}@example.com"
			guest_user = User.new(name: guest_name, email: guest_email, password: 
														guest_password, password_confirmation:
														guest_password, guest: true)
			guest_user.skip_confirmation_notification!
			guest_user.save!(validate: false)
			cookies.permanent.signed[:guest_user_id] = guest_user.id
			cookies.permanent.signed[:guest_password] = guest_password
			guest_user
		end
end
