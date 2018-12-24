class SignalBoost < ApplicationRecord
  has_one :status, as: :post, inverse_of: :post, dependent: :destroy
  belongs_to :origin, class_name: "Article", inverse_of: :signal_boosts, counter_cache: true
  validates :origin, presence: true

  def append(addition)
    update_attribute(:comment, comment+addition)
  end
end
