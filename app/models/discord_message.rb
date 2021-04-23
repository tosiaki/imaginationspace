class DiscordMessage < ApplicationRecord
  has_many :reactions, primary_key: :message_id, class_name: 'DiscordReaction'
  has_many :embeds, primary_key: :message_id, class_name: 'DiscordEmbed'
  has_many :attachments, primary_key: :message_id, class_name: 'DiscordAttachment'
end
