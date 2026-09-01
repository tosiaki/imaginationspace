require 'rails_helper'

RSpec.describe Article, type: :model do
  it "loads the latest replies per thread with one partitioned query" do
    now = Time.current
    root_ids = 2.times.map do |root_number|
      root_id = described_class.insert_all!([{
        title: "Root #{root_number}", thread_id: nil, reply_to_id: nil,
        anonymous: false, created_at: now, updated_at: now
      }], returning: ["id"]).rows.first.first
      described_class.where(id: root_id).update_all(thread_id: root_id)

      described_class.insert_all!((1..6).map do |reply_number|
        {
          title: "Thread #{root_number} reply #{reply_number}",
          thread_id: root_id,
          reply_to_id: root_id,
          anonymous: false,
          created_at: now + reply_number.seconds,
          updated_at: now + reply_number.seconds
        }
      end)
      root_id
    end
    roots = described_class.where(id: root_ids).order(:id).to_a

    sql = []
    subscriber = lambda do |_name, _start, _finish, _id, payload|
      sql << payload[:sql] unless %w[SCHEMA TRANSACTION CACHE].include?(payload[:name])
    end
    ActiveSupport::Notifications.subscribed(subscriber, "sql.active_record") do
      described_class.preload_recent_thread_posts(roots)
    end

    expect(sql.length).to eq(1)
    expect(sql.first).to include("ROW_NUMBER() OVER (PARTITION BY thread_id")
    expect(roots.map { |root| root.thread_posts.map(&:title) }).to eq([
      (2..6).map { |number| "Thread 0 reply #{number}" },
      (2..6).map { |number| "Thread 1 reply #{number}" }
    ])
  end
end
