module Concerns::Work
  extend ActiveSupport::Concern

  def add_kudos(user: nil, ip_address: nil)
    if user
      kudos.create(user: user) unless kudos_giver_users.include?(user)
    elsif ip_address
      kudos.create(ip_address: ip_address) unless guest_gave_kudos?(ip_address)
    end
  end

  def guest_gave_kudos?(ip_addr)
    kudos.exists?(ip_address: ip_addr)
  end

  def guest_kudos
    kudos.where(user: nil).count
  end

end