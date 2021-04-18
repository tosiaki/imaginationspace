module GuestFunctions
  extend ActiveSupport::Concern

  def guest_params
    unless user_signed_in?
      {
        display_name: cookies.permanent[:display_name],
        editing_password: cookies.permanent[:editing_password] ||= SecureRandom.urlsafe_base64
      }
    end
  end
end
