class Drawing < ApplicationRecord
  include Concerns::Validatable
  include Concerns::Work

  enum rating: { not_rated: 0, general_audiences: 1, teen_and_up_audiences: 2, mature: 3, explicit: 4 }
  enum orientation: { screen: 0, column: 1 }

  mount_uploader :drawing, DrawingUploader
  default_scope -> { order(created_at: :desc) }

  belongs_to :user
  validates :user_id, presence: true

  acts_as_taggable
  acts_as_taggable_on :fandoms, :characters, :relationships

  has_many :bookmarks, as: :bookmarkable
  has_many :bookmarked_users, through: :bookmarks, source: :user

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :total_comments, class_name: "Comment", as: :work

  has_many :kudos, as: :work, dependent: :destroy
  has_many :kudos_giver_users, through: :kudos, source: :user

  is_impressionable

  default_scope -> { order updated_at: :desc }

  validate :has_fandoms

  validates :drawing, presence: true
  validates :title, presence: true, length: { maximum: 255 }
  validates :caption, length: { maximum: 1250 }

  HAS_PAGES = false
end
