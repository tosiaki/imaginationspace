require "rails_helper"

RSpec.describe DiscordMessage, type: :model do
  it "preloads reactions alongside the leaderboard aggregate" do
    now = Time.current
    message = described_class.create!(message_id: 123, message_created_at: now)
    DiscordReaction.create!(discord_message_id: message.message_id, count: 2)

    messages = described_class
      .select("discord_messages.*, SUM(discord_reactions.count) AS reaction_count")
      .joins(:reactions)
      .preload(:reactions)
      .group("discord_messages.id")
      .where("message_created_at > ?", 30.days.ago)
      .order("reaction_count DESC")
      .limit(50)
      .to_a

    sql = []
    subscriber = lambda do |_name, _start, _finish, _id, payload|
      sql << payload[:sql] unless %w[SCHEMA TRANSACTION CACHE].include?(payload[:name])
    end
    ActiveSupport::Notifications.subscribed(subscriber, "sql.active_record") do
      messages.each { |record| record.reactions.to_a }
    end

    expect(sql).to be_empty
  end
end
