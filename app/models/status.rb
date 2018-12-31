class Status < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :post, polymorphic: true, inverse_of: :status

  # default_scope -> { order(timeline_time: :desc) }

  validates :post, presence: true
  validates_associated :post

  def self.select_by(tags: nil, user: nil, order: nil, bookmarked_by: nil, page_number: 1, count: false)
    status = Arel::Table.new(:statuses)

    if count
      relation = status.project("COUNT(*)")
    else
      relation = status.project(status[Arel.sql("*")])
    end

    if tags.present? || %w(bookmarks kudos signal_boosts replies hits).include?(order) || bookmarked_by.present?
      article = Arel::Table.new(:articles)
      relation.join(article).on(status[:post_id].eq(article[:id]).and(status[:post_type].eq("Article")))
    end

    if tags.present?
      tags.each_with_index do |tag,index|
        arel_table_tagging = Arel::Table.new(:article_taggings, as: "tagging#{index}")
        arel_table_tag = Arel::Table.new(:article_tags, as: "tag#{index}")
        relation = relation.join(arel_table_tagging).on(article[:id].eq(arel_table_tagging[:article_id])).
        join(arel_table_tag).on(arel_table_tagging[:article_tag_id].eq(arel_table_tag[:id])).where(arel_table_tag[:name].eq(tag))
      end
    end

    if user
      user_table = User.arel_table
      relation = relation.join(user_table).on(status[:user_id].eq(user_table[:id])).where(user_table[:id].eq(user.id))
    end

    if bookmarked_by
      bookmarks_table = Bookmark.arel_table
      relation = relation.join(bookmarks_table).on(article[:id].eq(bookmarks_table[:bookmarkable_id]).and(bookmarks_table[:bookmarkable_type].eq("Article"))).where(bookmarks_table[:user_id].eq(bookmarked_by.id))
    end

    relation = relation.group(status[:id])

    case order
    when 'published'
      relation = relation.order(status[:created_at].desc)
    when 'bookmarks'
      relation = relation.order(article[:bookmarks_count].desc)
    when 'kudos'
      relation = relation.order(article[:kudos_count].desc)
    when 'signal_boosts'
      relation = relation.order(article[:signal_boosts_count].desc)
    when 'replies'
      relation = relation.order(article[:reply_number].desc)
    when 'hits'
      relation = relation.order(article[:impressions_count].desc)
    else
      relation = relation.order(status[:timeline_time].desc)
    end

    if count
      self.find_by_sql(relation.to_sql).count
    else
      relation = relation.skip((page_number-1)*self.number_per_page).take(self.number_per_page)
      result = self.find_by_sql(relation.to_sql)
      class << result
        attr_accessor :total_entries, :per_page, :current_page

        def total_pages
          (total_entries/per_page.to_f).ceil
        end
      end
      result.total_entries = self.select_by(tags: tags, user: user, order: order, bookmarked_by: bookmarked_by, page_number: page_number, count: true)
      result.per_page = self.number_per_page
      result.current_page = page_number
      result
    end
  end

  def self.number_per_page
    @number ||= 20
  end
end
