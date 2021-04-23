module LeaderboardHelper
  def get_author(user_id)
    "@#{DiscordUser.find_by(user_id: user_id).user_display_name}"
  end

  def insert_references(message)
    message
      .gsub(/<:\w+:(\d+)>/) { image_tag "https://cdn.discordapp.com/emojis/#{$1}.png", class: "message-emoji" }
      .gsub(/<@!(\d+)>/) { self.get_author $1 }
      .html_safe
  end
end
