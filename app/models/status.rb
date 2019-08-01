class Status < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :post, polymorphic: true, inverse_of: :status
  belongs_to :article, foreign_key: 'post_id', optional: true
  belongs_to :signal_boost, foreign_key: 'post_id', optional: true
  # belongs_to :article, -> { where(statuses: {post_type: "Article"}) }, foreign_key: 'post_id', optional: true

  # default_scope -> { order(timeline_time: :desc) }

  validates :post, presence: true
  validates_associated :post

  def article
    return unless post_type == "Article"
    super
  end

  def self.select_by(tags: nil, user: nil, order: nil, bookmarked_by: nil, page_number: 1, count: false, include_replies: false, filter_languages_user: nil, filter_maps: true)
    status = Arel::Table.new(:statuses)

    if count
      relation = status.project("COUNT(*)")
    else
      relation = status.project(status[Arel.sql("*")])
    end

    article = Arel::Table.new(:articles)
    if tags.present? || %w(bookmarks kudos signal_boosts replies hits).include?(order) || bookmarked_by.present?
      join_on = status[:post_id].eq(article[:id]).and(status[:post_type].eq("Article"))
      unless include_replies
        join_on = join_on.and(article[:reply_to_id].eq(nil))
      end
      relation.join(article).on(join_on)
    else
      article_condition = article[:id].not_eq(nil)
      unless include_replies
        article_condition = article_condition.and(article[:reply_to_id].eq(nil))
      end
      relation.join(article, Arel::Nodes::OuterJoin).on(status[:post_id].eq(article[:id]).and(article[:anonymous].eq(false))).where(article_condition.or(status[:post_type].eq("SignalBoost")))
    end

    if tags.present?
      tags.each_with_index do |tag,index|
        arel_table_tagging = Arel::Table.new(:article_taggings, as: "tagging#{index}")
        arel_table_tag = Arel::Table.new(:article_tags, as: "tag#{index}")
        relation = relation.join(arel_table_tagging).on(article[:id].eq(arel_table_tagging[:article_id])).
        join(arel_table_tag).on(arel_table_tagging[:article_tag_id].eq(arel_table_tag[:id])).where(arel_table_tag[:name].eq(tag))
      end
    end

    if false && filter_languages_user
      arel_language_tagging = Arel::Table.new(:article_taggings, as: "languagetagging")
      arel_language_tag = Arel::Table.new(:article_tags, as: "languagetag")

      user_language = UserLanguage.arel_table

      exclude_articles = Arel::Table.new(:articles, as: "excludearticle")

      exclude_subquery = exclude_articles.project(exclude_articles[Arel.sql("*")]).join(arel_language_tagging).on(exclude_articles[:id].eq(arel_language_tagging[:article_id]))
      .join(arel_language_tag)
      .on(arel_language_tagging[:article_tag_id].eq(arel_language_tag[:id]).and(arel_language_tag[:context].eq("language")))
      .join(user_language, Arel::Nodes::OuterJoin)
      .on(arel_language_tag[:id].eq(user_language[:article_tag_id]).and(user_language[:user_id].eq(filter_languages_user.id)))
      .where(user_language[:id].eq(nil)).as('suba')

      relation = relation.join(exclude_subquery,Arel::Nodes::OuterJoin).on(article[:id].eq(exclude_subquery[:id])).where(exclude_subquery[:id].eq(nil))
    end

    if filter_maps
      arel_language_tagging1 = Arel::Table.new(:article_taggings, as: "languagetagging1")
      arel_language_tag1 = Arel::Table.new(:article_tags, as: "languagetag1")

      exclude_articles1 = Arel::Table.new(:articles, as: "excludearticle1")

      exclude_maps_subquery = exclude_articles1.project(exclude_articles1[Arel.sql("*")]).join(arel_language_tagging1).on(exclude_articles1[:id].eq(arel_language_tagging1[:article_id]))
      .join(arel_language_tag1)
      .on(arel_language_tagging1[:article_tag_id].eq(arel_language_tag1[:id])).where(arel_language_tag1[:name].eq("map community"))
      .as('subm')

      relation = relation.join(exclude_maps_subquery,Arel::Nodes::OuterJoin).on(article[:id].eq(exclude_maps_subquery[:id])).where(exclude_maps_subquery[:id].eq(nil))



      arel_language_tagging2 = Arel::Table.new(:article_taggings, as: "languagetagging2")
      arel_language_tag2 = Arel::Table.new(:article_tags, as: "languagetag2")

      exclude_articles2 = Arel::Table.new(:articles, as: "excludearticle2")

      exclude_boosts = Arel::Table.new(:signal_boosts, as: "excludeboosts")

      exclude_maps_subquery2 = exclude_boosts.project(exclude_boosts[Arel.sql("*")])
      .join(exclude_articles2).on(exclude_articles2[:id].eq(exclude_boosts[:origin_id]))
      .join(arel_language_tagging2).on(exclude_articles2[:id].eq(arel_language_tagging2[:article_id]))
      .join(arel_language_tag2)
      .on(arel_language_tagging2[:article_tag_id].eq(arel_language_tag2[:id])).where(arel_language_tag2[:name].eq("map community"))
      .as('subm2')

      relation = relation.join(exclude_maps_subquery2,Arel::Nodes::OuterJoin).on(status[:post_id].eq(exclude_maps_subquery2[:id]).and(status[:post_type].eq("SignalBoost")))
      .where(exclude_maps_subquery2[:id].eq(nil))
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
      relation = relation.group(status[:created_at]).order(status[:created_at].desc)
    when 'bookmarks'
      relation = relation.group(article[:bookmarks_count]).order(article[:bookmarks_count].desc)
    when 'kudos'
      relation = relation.group(article[:kudos_count]).order(article[:kudos_count].desc)
    when 'signal_boosts'
      relation = relation.group(article[:signal_boosts_count]).order(article[:signal_boosts_count].desc)
    when 'replies'
      relation = relation.group(article[:reply_number]).order(article[:reply_number].desc)
    when 'hits'
      relation = relation.group(article[:impressions_count]).order(article[:impressions_count].desc)
    else
      relation = relation.group(status[:timeline_time]).order(status[:timeline_time].desc)
    end

    if count
      self.find_by_sql(relation.to_sql).count
    else
      relation = relation.skip((page_number-1)*self.number_per_page).take(self.number_per_page)
      result = self.find_by_sql(relation.to_sql)

      class << result
        attr_accessor :total_entries, :per_page, :current_page, :preloaded_records

        def total_pages
          (total_entries/per_page.to_f).ceil
        end
      end
      result.total_entries = self.select_by(tags: tags, user: user, order: order, bookmarked_by: bookmarked_by, page_number: page_number, count: true, include_replies: include_replies, filter_maps: filter_maps)
      result.per_page = self.number_per_page
      result.current_page = page_number
      result
    end
  end

  def self.number_per_page
    @number ||= 20
  end
end
