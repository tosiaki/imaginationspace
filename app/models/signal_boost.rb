class SignalBoost < ApplicationRecord
  has_one :status, as: :post, inverse_of: :post, dependent: :destroy
  has_many :shrine_pictures, as: :page
  belongs_to :origin, class_name: "Article", inverse_of: :signal_boosts, counter_cache: true, optional: true
  before_save :strip_end_whitespace
  after_create :notify_user

  def strip_end_whitespace
    self.comment = comment.strip
  end

  def content
    comment
  end

  def notify_user
    if origin.user && origin.user.notify_signal_boost
      NotificationMailer.signal_boost(status.user, origin).deliver_now
    end
  end
end
