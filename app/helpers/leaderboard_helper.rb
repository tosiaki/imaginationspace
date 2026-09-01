module LeaderboardHelper
  def get_author(user_id)
    display_name = (@discord_user_names || {})[user_id.to_i]
    "@#{display_name || user_id}"
  end

  def insert_references(message)
    message.to_s.split(/(<:\w+:\d+>|<@!?\d+>)/).map do |segment|
      if (emoji_id = segment.match(/\A<:\w+:(\d+)>\z/)&.captures&.first)
        image_tag "https://cdn.discordapp.com/emojis/#{emoji_id}.png",
          class: "message-emoji", loading: "lazy", decoding: "async"
      elsif (user_id = segment.match(/\A<@!?(\d+)>\z/)&.captures&.first)
        ERB::Util.html_escape(get_author(user_id))
      else
        ERB::Util.html_escape(segment)
      end
    end.join.html_safe
  end

  def external_http_url(value)
    uri = URI.parse(value.to_s)
    uri.to_s if uri.host.present? && %w[http https].include?(uri.scheme)
  rescue URI::InvalidURIError
    nil
  end

  def external_host?(value, host)
    url = external_http_url(value)
    url && URI.parse(url).host == host
  end

  def deferred_video_embed(source_url, title:, external_url: source_url)
    source = external_http_url(source_url)
    destination = external_http_url(external_url)
    return unless source && destination

    content_tag(:div, class: "deferred-video-embed") do
      button_tag("Load #{title}", type: "button", class: "deferred-video-load",
        data: { embed_src: source, embed_title: title }) +
        link_to("Open on provider", destination, target: "_blank",
          rel: "nofollow ugc noopener noreferrer", class: "deferred-video-link")
    end
  end
end
