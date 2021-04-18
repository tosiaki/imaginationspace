class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  after_create :subscribe_to_self

  mount_uploader :icon, IconUploader

  has_one :legacy_user

  has_many :statuses
  has_many :articles, through: :statuses, source: :post, source_type: "Article"
  belongs_to :sticky, class_name: "Article", optional: true
  has_many :signal_boosts, through: :statuses, source: :post, source_type: "SignalBoost"
  has_many :signal_boosted_articles, through: :signal_boosts, source: :origin

  has_many :drawings, -> { where authorship: :own }
  has_many :comics, -> { where authorship: :own }
  has_many :drawing_translations, -> { where authorship: :scanlation }, class_name: "Drawing"
  has_many :scanlations, -> { where authorship: :scanlation }, class_name: "Comic"

  has_many :bookmarks, inverse_of: :user
  has_many :bookmarked_drawings, through: :bookmarks, source: :bookmarkable, source_type: 'Drawing'
  has_many :bookmarked_comics, through: :bookmarks, source: :bookmarkable, source_type: 'Comic'
  has_many :bookmarked_articles, through: :bookmarks, source: :bookmarkable, source_type: 'Article'
  has_many :comments, inverse_of: :user

  has_many :subscriptions, through: :bookmarks, source: :bookmarkable, source_type: 'User'
  has_many :feed_drawings, through: :subscriptions, source: :drawings
  has_many :feed_comics, through: :subscriptions, source: :comics
  has_many :feed_statuses, -> { order(timeline_time: :desc).joins("LEFT OUTER JOIN articles ON statuses.post_id = articles.id AND statuses.post_type = 'Article'").where("statuses.post_type = 'SignalBoost' OR articles.anonymous = false") }, through: :subscriptions, source: :statuses

  has_many :subscribeds, foreign_key: :bookmarkable, class_name: "Bookmark"
  has_many :subscribers, through: :subscribeds, source: :user

  validates :name, presence: true, length: { maximum: 255 }
  validates :title, length: { maximum: 255 }
  validates :bio, length: { maximum: 2000 }
  validates :website, length: { maximum: 255 }

  has_many :user_languages
  has_many :language_tags, through: :user_languages, source: :article_tag

  has_many :series

  def after_confirmation
    update_attribute(:guest, false)
  end

  def valid_password?(password)
    if legacy_password == 1
      if legacy_user.validate(password)
        self.password = password
        self.legacy_password = 0
        self.save!
        true
      else
        false
      end
    else
      super
    end
  end

  def reset_password!(*args)
    self.legacy_password = 0
    super
  end

  def is_subscribed_to?(user)
    @subscriptions ||= subscriptions.to_a
    @subscriptions.include?(user)
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

  def languages
    language_array.join(", ")
  end

  def language_array
    language_tags.pluck(:name)
  end

  def add_tag(new_tag)
    tag = ArticleTag.find_by(name: new_tag, context: "language")
    tag ||= ArticleTag.create(name: new_tag, context: "language")
    user_languages.create(article_tag: tag)
  end

  def remove_tag(old_tag)
    tag = ArticleTag.find_by(name: old_tag, context: "language")
    tag.user_languages.where(user_id: id).map(&:destroy)
  end

  def add_tags(tag_array)
    tag_array.each do |tag|
      add_tag(tag)
    end
  end

  def remove_tags(tag_array)
    tag_array.each do |tag|
      remove_tag(tag)
    end
  end

  def set_languages(tags)
    new_tags = tags.split(/\s*,\s*/).reject { |c| c.empty? }
    old_tags = language_array
    unless new_tags == old_tags
      remove_tags(old_tags - new_tags)
      add_tags(new_tags - old_tags)
    end
  end

  def filter_content?
    !language_array.include?('map community')
  end
end
