class SignalBoost < ApplicationRecord
  has_one :status, as: :post, inverse_of: :post, dependent: :destroy
  belongs_to :origin, class_name: "Article", inverse_of: :signal_boosts, counter_cache: true, optional: true
  before_save :strip_end_whitespace

  def append(addition)
    update_attribute(:comment, comment+addition)
  end

  def strip_end_whitespace
    self.comment = comment.strip
  end
end
