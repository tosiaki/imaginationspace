class LegacyUser < ApplicationRecord
  belongs_to :user

  def validate(password)
    legacy_password_digest == Digest::SHA256.base64digest(legacy_username + password + ENV['LEGACY_SALT'])[0..-2]
  end
end
