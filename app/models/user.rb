class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  after_create :subscribe_to_self

  mount_uploader :icon, IconUploader

  has_many :statuses
  has_many :articles, through: :statuses, source: :post, source_type: "Article"
  belongs_to :sticky, class_name: "Article"
  has_many :signal_boosts, through: :statuses, source: :post, source_type: "SignalBoost"

  has_many :drawings, -> { where authorship: :own }
  has_many :comics, -> { where authorship: :own }
  has_many :drawing_translations, -> { where authorship: :scanlation }, class_name: "Drawing"
  has_many :scanlations, -> { where authorship: :scanlation }, class_name: "Comic"

  has_many :bookmarks, inverse_of: :user
  has_many :bookmarked_drawings, through: :bookmarks, source: :bookmarkable, source_type: 'Drawing'
  has_many :bookmarked_comics, through: :bookmarks, source: :bookmarkable, source_type: 'Comic'
  has_many :comments, inverse_of: :user

  has_many :subscriptions, through: :bookmarks, source: :bookmarkable, source_type: 'User'
  has_many :feed_drawings, through: :subscriptions, source: :drawings
  has_many :feed_comics, through: :subscriptions, source: :comics
  has_many :feed_statuses, -> { order(timeline_time: :desc) }, through: :subscriptions, source: :statuses

  has_many :subscribeds, foreign_key: :bookmarkable, class_name: "Bookmark"
  has_many :subscribers, through: :subscribeds, source: :user

  validates :name, presence: true, length: { maximum: 255 }
  validates :title, length: { maximum: 255 }
  validates :bio, length: { maximum: 2000 }

  def is_subscribed_to?(user)
    subscriptions.include?(user)
  end

  def subscribe_to_self
    bookmarks.create(bookmarkable: self) unless is_subscribed_to? self
  end

  def proper_subscriptions
    subscriptions.where.not id: id
  end

  def proper_subscribers
    subscribers.where.not id: id
  end

  def subscribers_count
    @subscribers_count ||= proper_subscribers.count
  end

  def subscriptions_count
    @subscriptions_count ||= proper_subscriptions.count
  end
end
