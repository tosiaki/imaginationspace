class ArticleTag < ApplicationRecord
  has_many :article_taggings
  has_many :articles, through: :article_taggings

  validates :name, presence: true

  def self.associate_tags(context: nil, tags: nil, user: nil, bookmarked_by: nil, exclusions: nil)
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
      relation = relation.join(status).on(status[:post_id].eq(article[:id]).and(status[:post_type].eq("Article")))

      relation = relation.where(status[:user_id].eq(user[:id]))
    end
    if bookmarked_by
      bookmarks = Arel::Table.new(:bookmarks)
      relation = relation.join(bookmarks).on(bookmarks[:bookmarkable_id].eq(article[:id]).and(bookmarks[:bookmarkable_type].eq("Article"))).where(bookmarks[:user_id].eq(bookmarked_by.id))
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
      { context: 'attribution', name: "Attribution"}
    ]
  end

  def self.tag_box_contexts
    @contexts = self.contexts.reject{ |context| context[:name] == "Media"}
  end

  def self.context_strings
    @strings ||= self.contexts.map{|c| c[:context]}
  end

  def self.context_names
    @names ||= self.contexts.map{|c| c[:name]}
  end

  scope :find_tags, ->(starting_with:, context: nil) do
    result_scope = where("name LIKE ?", "#{sanitize_sql_like(starting_with)}%").joins(:articles)
    result_scope = result_scope.where(context: context) if context
    result_scope.select("article_tags.name, COUNT(articles.id) as article_count").group(:article_tag_name).group(:article_tag_id).order("article_count DESC").limit(20)
  end
end
