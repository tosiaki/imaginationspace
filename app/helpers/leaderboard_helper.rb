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

  def image_from_url(url)
    begin
      if Nokogiri::HTML(open(url)).css("meta[property='og:image']").present?
        Nokogiri::HTML(open(url)).css("meta[property='og:image']").first.attributes['content'].value
      else
        url
      end
    rescue
      url
    end
  end
end
