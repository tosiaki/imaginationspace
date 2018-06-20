class Comic < ApplicationRecord
  include Concerns::Validatable

  enum rating: { not_rated: 0, general_audiences: 1, teen_and_up_audiences: 2, mature: 3, explicit: 4 }
  enum front_page_rating: { front_not_rated: 0, front_general_audiences: 1, front_teen_and_up_audiences: 2, front_mature: 3, front_explicit: 4 }

  belongs_to :user
  validates :user_id, presence: true
  has_many :comic_pages, inverse_of: :comic, dependent: :destroy

  acts_as_taggable
  acts_as_taggable_on :fandoms, :characters, :relationships
  validate :has_fandoms
  validate :check_pages

  validates :title, presence: true
  validates :pages, presence: true
  validates_numericality_of :pages, only_integer: true, greater_than_or_equal_to: 0, message: "Pages must be an a positive integer"

  def check_pages
    errors.add :base, "A comic needs to have at least one page." if self.comic_pages.blank?
  end

  def has_pages?
    true
  end
end
