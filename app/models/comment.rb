class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :work, polymorphic: true
  belongs_to :user, inverse_of: :comments, optional: true

  has_many :comments, as: :commentable, dependent: :destroy

  validates :content, presence: true, length: { maximum: 4300 }
  validates :name, presence: true, length: { maximum: 255 }, unless: :user_id?
  validates :email, presence: true, length: { maximum: 255 }, unless: :user_id?
  validates_presence_of :user, if: :user_id?

  default_scope -> { order id: :asc }
end
