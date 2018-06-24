class Comic < ApplicationRecord
  include Concerns::Validatable
  include Concerns::Work

  enum rating: { not_rated: 0, general_audiences: 1, teen_and_up_audiences: 2, mature: 3, explicit: 4 }
  enum front_page_rating: { front_not_rated: 0, front_general_audiences: 1, front_teen_and_up_audiences: 2, front_mature: 3, front_explicit: 4 }

  belongs_to :user
  validates :user_id, presence: true
  has_many :comic_pages, inverse_of: :comic, dependent: :destroy

  acts_as_taggable
  acts_as_taggable_on :fandoms, :characters, :relationships

  has_many :bookmarks, as: :bookmarkable
  has_many :bookmarked_users, through: :bookmarks, source: :user
  
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :total_comments, class_name: "Comment", as: :work

  has_many :kudos, as: :work, dependent: :destroy
  has_many :kudos_giver_users, through: :kudos, source: :user

  is_impressionable

  validate :has_fandoms
  validate :check_pages

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 1250 }
  validates :pages, presence: true
  validates_numericality_of :pages, only_integer: true, greater_than_or_equal_to: 0, message: "Pages must be an a positive integer"

  HAS_PAGES = true

  def check_pages
    errors.add :base, "A comic needs to have at least one page." if self.comic_pages.blank?
  end
end
