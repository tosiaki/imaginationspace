class Article < ApplicationRecord
  has_one :status, as: :post, inverse_of: :post, dependent: :destroy
  has_one :user, through: :status
  has_many :pages, inverse_of: :article, dependent: :destroy
  validates_associated :pages

  belongs_to :reply_to, class_name: "Article", optional: true
  has_many :replies, class_name: "Article", foreign_key: :reply_to

  has_many :signal_boosts, foreign_key: :origin_id, inverse_of: :origin, dependent: :destroy
  has_many :kudos, as: :work, dependent: :destroy, inverse_of: :work
  has_many :kudos_giver_users, through: :kudos, source: :user
  has_many :bookmarks, as: :bookmarkable, dependent: :destroy
  has_many :bookmarked_users, through: :bookmarks, source: :user

  has_many :article_taggings, dependent: :destroy
  has_many :article_tags, through: :article_taggings

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

  validate :check_pages

  before_destroy :remove_replies

  def update_page(content:, page_number:, title: "")
    page = pages.find_by( page_number: page_number )
    page.update_attributes(content: content, title: title)
  end

  def add_page(content: "", page_number:, title: "")
    page_result = pages.create(content: content, page_number: page_number, title: title)
    update_timeline_time
    page_result
  end

  def append(content:, page_number:)
    page = pages.find_by( page_number: page_number )
    page ||= add_page(page_number: page_number)
    page.append(content)
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

  def check_pages
    errors.add :base, "An article needs to have at least one page." if self.pages.blank?
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
end