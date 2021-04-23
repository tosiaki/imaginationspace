class LeaderboardController < ApplicationController
  def weekly
    @messages = DiscordMessage.select(
      'discord_messages.*, SUM(discord_reactions.count) as reaction_count'
    ).
    joins(:reactions).
    includes(:embeds).
    includes(:attachments).
    group('discord_messages.id').
    where('message_created_at > ?', 30.days.ago).
    order('reaction_count DESC').
    limit(50)
  end
end
