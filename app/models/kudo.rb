class Kudo < ApplicationRecord
  belongs_to :work, polymorphic: true, counter_cache: true
  belongs_to :user, optional: true
  validates :ip_address, presence: true, unless: :user_id?
  validates_presence_of :user, if: :user_id?

  default_scope -> { order(created_at: :asc) }

  after_save :notify_user

  def notify_user
    if work.user.notify_kudos
      NotificationMailer.kudos(work, user).deliver_now
    end
  end
end
