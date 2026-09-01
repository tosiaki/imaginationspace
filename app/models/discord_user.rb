class DiscordUser < ApplicationRecord
  def self.display_names_for(messages)
    ids = DiscordMessage.referenced_user_ids(messages)
    where(user_id: ids).pluck(:user_id, :user_display_name).to_h
  end
end
