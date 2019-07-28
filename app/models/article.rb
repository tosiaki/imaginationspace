class Article < ApplicationRecord
  has_one :status, as: :post, inverse_of: :post, dependent: :destroy
  has_one :user, through: :status
  has_many :pages, inverse_of: :article, dependent: :delete_all

  belongs_to :reply_to, class_name: "Article", optional: true
  has_many :replies, -> { order(kudos_count: :desc) }, class_name: "Article", foreign_key: :reply_to

  has_many :signal_boosts, foreign_key: :origin_id, inverse_of: :origin
  has_many :kudos, as: :work, dependent: :destroy, inverse_of: :work
  has_many :kudos_giver_users, through: :kudos, source: :user
  has_many :bookmarks, as: :bookmarkable, dependent: :destroy
  has_many :bookmarked_users, through: :bookmarks, source: :user

  has_many :article_taggings, dependent: :destroy
  has_many :article_tags, through: :article_taggings

  validates :pages, presence: true
  validate :check_editing_password

  before_save :normalize_planned_pages

  before_destroy :check_editing_password
  before_destroy :remove_replies
  before_destroy :remove_reply_number
  before_destroy :null_signal_boost_origins

  is_impressionable counter_cache: true, unique: :session_hash

  attr_accessor :signed_in
  attr_accessor :editing_password

  after_create :notify_user

  # scope :tagged_with, -> (tags, context=nil) do
  #   if tags.length > 0
  #     arel_table_tagging = Arel::Table.new(:article_taggings, as: "tagging#{tags.length}")
  #     arel_table_tag = Arel::Table.new(:article_tags, as: "tag#{tags.length}")
  #     select_tag = ArticleTag.find_by({name: tags.first, context: context}.delete_if {|value, key| key.nil? })
  #     if select_tag
  #       join(arel_table_tagging).on(arel_tabble_tagging[:article_id].eq)
  #       joins(article_taggings: :article_tag).merge(select_tag.articles).tagged_with(tags[1..-1], context)
  #     end
  #   end
  # end

  # def add_tag_context(name)
  #   has_many "#{name}_tags".to_sym, through: :article_taggings, -> { where(type: name) }
  # end
  # ['fandom', 'character', 'relationship', 'other'].each { |c| add_tag_context(c) }

  def media
    @media = article_tags.where(context: 'media').first
    @media ||= ArticleTag.find_by(name: 'Status', context: "media")
  end

  def fandom
    tag_string('fandom')
  end

  def character
    tag_string('character')
  end

  def relationship
    tag_string('relationship')
  end

  def other
    tag_string('other')
  end

  def language
    tag_string('language')
  end

  def attribution
    tag_string('attribution')
  end

  def fandom_tags
    article_tags.where(context: 'fandom')
  end

  def character_tags
    article_tags.where(context: 'character')
  end

  def relationship_tags
    article_tags.where(context: 'relationship')
  end

  def other_tags
    article_tags.where(context: 'other')
  end

  def attribution_tags
    article_tags.where(context: 'attribution')
  end

  def authored_by
    if anonymous
      "Anonymous"
    elsif user
      user.name
    else
      if display_name.present?
        display_name
      else
        "Anonymous"
      end
    end
  end
  
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def hash_editing_password
    unless user
      self.editing_password_digest = Article.digest(editing_password)
    end
  end

  # Unused
  def update_page(content:, page_number:, title: "")
    touch
    page = pages.find_by( page_number: page_number )
    page.update_attributes(content: content, title: title)
  end

  def remove_page(page_number)
    touch
    page = pages.find_by( page_number: page_number )
    page.remove_page
  end

  def current_max_page
    maximum ||= pages.map(&:page_number).max
  end

  def next_page
    current_max_page + 1
  end

  def make_room_at_page(page_number)
    pages.reload
    pages.where( page_number: page_number ).each do |page|
      page.move_up
    end
  end

  def update_timeline_time
    pages.reload
    if max_pages < current_max_page
      update_attribute(:max_pages, current_max_page)
      status.update_attribute(:timeline_time, Time.now)
    end
  end

  def normalize_planned_pages
    self.planned_pages = planned_pages.abs.round || 1
    if planned_pages != 0 && planned_pages < pages.count
      self.planned_pages = pages.count
    end
  end

  def update_planned_pages
    normalize_planned_pages
    update_attribute(:planned_pages, planned_pages)
  end

  def check_pages
    errors.add :base, "An article needs to have at least one page." if self.pages.blank?
  end

  def check_editing_password
    hash_editing_password if new_record? && editing_password_digest.nil?
    unless user || BCrypt::Password.new(editing_password_digest).is_password?(editing_password)
      errors.add(:editing_password, "does not match.")
      throw :abort
    end
  end

  def ensure_validity
    throw :abort unless valid?
  end

  def add_kudos(user: nil, ip_address: nil)
    if user
      if kudos_giver_users.include?(user)
        :already_gave_kudos
      else
        kudos.create(user: user)
      end
    elsif ip_address
      if guest_gave_kudos?(ip_address)
        :already_gave_kudos
      else
        kudos.create(ip_address: ip_address)
      end
    end
  end

  def guest_gave_kudos?(ip_addr)
    kudos.exists?(ip_address: ip_addr)
  end

  def guest_kudos
    kudos.where(user: nil).count
  end

  def add_reply
    increment!(:reply_number)
    if reply_to
      reply_to.add_reply
    end
  end

  def remove_replies
    replies.all.map{ |r| r.update_attribute(:reply_to, nil) }
  end

  def decrease_reply_number(number)
    if reply_to
      reply_to.decrease_reply_number(number)
    end
    update_attribute(:reply_number, reply_number-number)
  end

  def remove_reply_number
    if reply_to
      reply_to.decrease_reply_number(1+reply_number)
    end
  end

  def add_tag(new_tag, context)
    tag = ArticleTag.find_by(name: new_tag, context: context)
    tag ||= ArticleTag.create(name: new_tag, context: context)
    article_taggings.create(article_tag: tag)
  end

  def remove_tag(old_tag, context)
    tag = ArticleTag.find_by(name: old_tag, context: context)
    tag.article_taggings.where(article_id: id).map(&:destroy)
  end

  def add_tags(tag_array, context)
    tag_array.each do |tag|
      add_tag(tag,context)
    end
  end

  def remove_tags(tag_array, context)
    tag_array.each do |tag|
      remove_tag(tag,context)
    end
  end

  def get_tags(context)
    article_tags.where(context: context).pluck(:name)
  end

  def tag_string(context)
    get_tags(context).join(', ')
  end

  def set_tags(tags, context)
    new_tags = tags.split(/\s*,\s*/).reject { |c| c.empty? }
    old_tags = get_tags(context)
    unless new_tags == old_tags
      remove_tags(old_tags - new_tags, context)
      add_tags(new_tags - old_tags, context)
    end
  end

  def null_signal_boost_origins
    signal_boosts.each do |signal_boost|
      signal_boost.update_attribute(:origin_id, nil)
    end
  end

  def admin_destroy
    self.editing_password = 'a'
    hash_editing_password
    destroy
  end

  def notify_user
    if reply_to && reply_to.user.notify_reply
      NotificationMailer.reply(reply_to, self, user).deliver_now
    end
  end
end