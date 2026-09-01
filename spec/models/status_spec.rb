require 'rails_helper'

RSpec.describe Status, type: :model do
  it "preloads everything read by a status listing without per-status queries" do
    now = Time.current
    root_id = Article.insert_all!([{
      title: "Root", thread_id: nil, reply_to_id: nil, reply_number: 1,
      anonymous: false, created_at: now, updated_at: now
    }], returning: ["id"]).rows.first.first
    Article.where(id: root_id).update_all(thread_id: root_id)

    reply_id = Article.insert_all!([{
      title: "Reply", thread_id: root_id, reply_to_id: root_id,
      anonymous: false, created_at: now + 1.second, updated_at: now + 1.second
    }], returning: ["id"]).rows.first.first
    Page.insert_all!([
      { article_id: root_id, page_number: 1, content: "Root page", created_at: now, updated_at: now },
      { article_id: reply_id, page_number: 1, content: "Reply page", created_at: now, updated_at: now }
    ])
    Status.insert_all!([
      { post_type: "Article", post_id: root_id, timeline_time: now, created_at: now, updated_at: now },
      { post_type: "Article", post_id: reply_id, timeline_time: now, created_at: now, updated_at: now }
    ])
    language_tag_id = ArticleTag.insert_all!([{
      name: "English", context: "language", created_at: now, updated_at: now
    }], returning: ["id"]).rows.first.first
    ArticleTagging.insert_all!([
      { article_id: root_id, article_tag_id: language_tag_id, created_at: now, updated_at: now },
      { article_id: reply_id, article_tag_id: language_tag_id, created_at: now, updated_at: now }
    ])

    statuses = Status.where(post_type: "Article", post_id: root_id).to_a
    ActiveRecord::Associations::Preloader.new(
      records: statuses,
      associations: described_class.listing_preloads
    ).call

    sql = []
    subscriber = lambda do |_name, _start, _finish, _id, payload|
      sql << payload[:sql] unless %w[SCHEMA TRANSACTION CACHE].include?(payload[:name])
    end
    ActiveSupport::Notifications.subscribed(subscriber, "sql.active_record") do
      article = statuses.first.article
      article.pages.to_a
      article.language_tags.to_a
      article.thread_posts.last(5).each do |reply|
        reply.pages.to_a
        reply.language_tags.to_a
      end
    end

    expect(sql).to be_empty
  end
end
