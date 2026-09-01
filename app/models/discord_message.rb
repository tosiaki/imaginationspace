class DiscordMessage < ApplicationRecord
  USER_MENTION_PATTERN = /<@!?(\d+)>/

  has_many :reactions, primary_key: :message_id, class_name: 'DiscordReaction'
  has_many :embeds, primary_key: :message_id, class_name: 'DiscordEmbed'
  has_many :attachments, primary_key: :message_id, class_name: 'DiscordAttachment'

  def self.referenced_user_ids(messages)
    Array(messages).flat_map do |message|
      message.content.to_s.scan(USER_MENTION_PATTERN).flatten
    end.map!(&:to_i).uniq
  end
end
