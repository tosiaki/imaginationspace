module Concerns::Work
  extend ActiveSupport::Concern

  def guest_gave_kudos?(ip_addr)
    kudos.exists?(ip_address: ip_addr)
  end

  def guest_kudos
    kudos.where(user: nil).count
  end

end