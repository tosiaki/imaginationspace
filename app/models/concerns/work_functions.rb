module WorkFunctions
  extend ActiveSupport::Concern

  included do
    after_save :announce_to_users
  end

  def add_kudos(user: nil, ip_address: nil)
    if user
      if kudos_giver_users.include?(user)
        :already_gave_kudos
      else
        kudos.build(user: user).save
      end
    elsif ip_address
      if guest_gave_kudos?(ip_address)
        :already_gave_kudos
      else
        kudos.build(ip_address: ip_address).save
      end
    end
  end

  def guest_gave_kudos?(ip_addr)
    kudos.exists?(ip_address: ip_addr)
  end

  def guest_kudos
    kudos.where(user: nil).count
  end

  def announce_to_users
    User.where(site_updates: true).each do |user|
      SubscriptionMailer.notification(work: self, user: user).deliver_now
    end
  end

end
