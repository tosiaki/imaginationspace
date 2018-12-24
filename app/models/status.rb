class Status < ApplicationRecord
  belongs_to :user
  belongs_to :post, polymorphic: true, inverse_of: :status

  # default_scope -> { order(timeline_time: :desc) }

  validates :user_id, presence: true
  validates :post, presence: true

  def self.select_by(tags: nil, user: nil, order: nil)
    status = Arel::Table.new(:statuses)
    relation = status.project(status[Arel.sql("*")])

    if tags.present? || %w(kudos signal_boosts replies).include?(order)
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
    relation = relation.group(status[:id])

    case order
    when 'published'
      relation = relation.order(status[:created_at].desc)
    when 'kudos'
      relation = relation.order(article[:kudos_count].desc)
    when 'signal_boosts'
      relation = relation.order(article[:signal_boosts_count].desc)
    when 'replies'
      relation = relation.order(article[:reply_number].desc)
    else
      relation = relation.order(status[:timeline_time].desc)
    end

    self.find_by_sql(relation.to_sql)
  end
end
