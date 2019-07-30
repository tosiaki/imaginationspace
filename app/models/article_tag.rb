class ArticleTag < ApplicationRecord
  has_many :article_taggings
  has_many :articles, through: :article_taggings

  has_many :user_languages

  validates :name, presence: true

  def self.associate_tags(context: nil, tags: nil, user: nil, bookmarked_by: nil, exclusions: nil, include_replies: false, filter_maps: true)
    article_tags = Arel::Table.new(:article_tags)
    relation = article_tags.project(article_tags[Arel.sql("*")],article_tags[:id].count.as('count'))

    if context
      relation = relation.where(article_tags[:context].eq(context))
    end
    if exclusions
      relation = relation.where(article_tags[:name].not_in exclusions)
    end

    article = Arel::Table.new(:articles)
    taggings = Arel::Table.new(:article_taggings)
    relation = relation.join(taggings).on(article_tags[:id].eq(taggings[:article_tag_id])).
    join(article).on(taggings[:article_id].eq(article[:id]))
    unless include_replies
      relation = relation.where(article[:reply_to_id].eq(nil))
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
      status = Arel::Table.new(:statuses)
      relation = relation.join(status).on(status[:post_id].eq(article[:id]).and(status[:post_type].eq("Article")).and(article[:anonymous].eq(false)))

      relation = relation.where(status[:user_id].eq(user[:id]))
    end
    if bookmarked_by
      bookmarks = Arel::Table.new(:bookmarks)
      relation = relation.join(bookmarks).on(bookmarks[:bookmarkable_id].eq(article[:id]).and(bookmarks[:bookmarkable_type].eq("Article"))).where(bookmarks[:user_id].eq(bookmarked_by.id))
    end

    if filter_maps
      arel_language_tagging1 = Arel::Table.new(:article_taggings, as: "languagetagging")
      arel_language_tag1 = Arel::Table.new(:article_tags, as: "languagetag")

      exclude_articles1 = Arel::Table.new(:articles, as: "excludearticle")

      exclude_maps_subquery = exclude_articles1.project(exclude_articles1[Arel.sql("*")]).join(arel_language_tagging1).on(exclude_articles1[:id].eq(arel_language_tagging1[:article_id]))
      .join(arel_language_tag1)
      .on(arel_language_tagging1[:article_tag_id].eq(arel_language_tag1[:id])).where(arel_language_tag1[:context].eq("fandom").and(arel_language_tag1[:name].eq("map community")))
      .as('subm')

      relation = relation.join(exclude_maps_subquery,Arel::Nodes::OuterJoin).on(article[:id].eq(exclude_maps_subquery[:id])).where(exclude_maps_subquery[:id].eq(nil))
    end

    relation = relation.group(article_tags[:id]).order(article_tags[:id].count.desc)
    self.find_by_sql(relation.to_sql)
  end

  # scope :associate_tags, -> (tags: nil, user: nil) do
  #   current_scope = joins(article_taggings: :article)
  #   if tags
  #     current_scope = current_scope.merge(Article.tagged_with(tags))
  #   end
  #   if user
  #     current_scope = current_scope.merge(user.articles)
  #   end
  #   current_scope.group(:id).order('COUNT(*) DESC')
  # end

  def self.contexts
    [
      { context: 'media', name: "Media"},
      { context: 'fandom', name: "Fandoms"},
      { context: 'relationship', name: "Relationships"},
      { context: 'character', name: "Characters"},
      { context: 'other', name: "Other tags"},
      { context: 'language', name: "Language"},
      { context: 'attribution', name: "Attribution"}
    ]
  end

  def self.tag_box_contexts
    @contexts = self.contexts.reject{ |context| context[:name] == "Media"}
  end

  def self.front_page_contexts
    @front_contexts = self.tag_box_contexts.reject{ |context| %w(Relationships Attribution).include? context[:name] }
  end

  def self.context_strings
    @strings ||= self.contexts.map{|c| c[:context]}
  end

  def self.context_names
    @names ||= self.contexts.map{|c| c[:name]}
  end

  scope :get_top_tags, ->(context, number) do
    where("context=?", context).where.not(name: ['map', 'nomap', 'map community', 'map positivity', 'mappositivity', 'Nomap', 'Map', 'Map positivity']).joins(:articles).select("article_tags.name, COUNT(articles.id) as article_count").group(:name).group(:article_tag_id).order("article_count DESC").limit(number)
  end

  scope :find_tags, ->(starting_with:, context: nil) do
    result_scope = where("name ILIKE ?", "#{sanitize_sql_like(starting_with.downcase)}%").joins(:articles)
    result_scope = result_scope.where(context: context) if context
    result_scope.select("article_tags.name, COUNT(articles.id) as article_count").group(:name).group(:article_tag_id).order("article_count DESC").limit(20)
  end
end
