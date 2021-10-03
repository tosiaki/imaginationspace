module ApplicationCable
  class Connection < ActionCable::Connection::Base
    # identified_by :current_user, :guest_user_id



    def connect
# 			self.current_user = find_verified_user
# 			logger.add_tags 'ActionCable', self.current_user.name
		end

		protected

			def find_verified_user
				if verified_user = env['warden'].user
					verified_user
				else
					guest_user
				end
			end

			def guest_user(with_retry = true)
				user = User.find_by(id: cookies.signed[:guest_user_id], guest: true)
				if user && user.valid_password?(cookies.signed[:guest_password])
					# Cache the value the first time it's gotten.
					@cached_guest_user = user
				else
					reject_unauthorized_connection
				end
			end

  end
end
