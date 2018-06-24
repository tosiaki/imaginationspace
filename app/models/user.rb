class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  mount_uploader :icon, IconUploader

  has_many :drawings
  has_many :comics

  has_many :bookmarks, inverse_of: :user
  has_many :bookmarked_drawings, through: :bookmarks, source: :bookmarkable, source_type: 'Drawing'
  has_many :bookmarked_comics, through: :bookmarks, source: :bookmarkable, source_type: 'Comic'
  has_many :comments, inverse_of: :user

  has_many :subscriptions, through: :bookmarks, source: :bookmarkable, source_type: 'User'
  has_many :feed_drawings, through: :subscriptions, source: :drawings
  has_many :feed_comics, through: :subscriptions, source: :comics

  validates :name, presence: true, length: { maximum: 255 }
  validates :title, length: { maximum: 255 }
  validates :bio, length: { maximum: 2000 }

  def is_subscribed_to?(user)
    subscriptions.include?(user)
  end
end
