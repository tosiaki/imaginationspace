class Drawing < ApplicationRecord
  include Concerns::Validatable

  enum rating: { not_rated: 0, general_audiences: 1, teen_and_up_audiences: 2, mature: 3, explicit: 4 }

  belongs_to :user
  validates :user_id, presence: true

  mount_uploader :drawing, DrawingUploader
  default_scope -> { order(created_at: :desc) }

  acts_as_taggable
  acts_as_taggable_on :fandoms, :characters, :relationships
  validate :has_fandoms

  validates :drawing, presence: true
  validates :title, presence: true

  def has_pages?
    false
  end
end
