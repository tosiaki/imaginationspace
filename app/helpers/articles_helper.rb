module ArticlesHelper
  def planned_pages_display(page_number)
    if page_number > 0
      page_number
    else
      "?"
    end
  end

  def can_edit(article)
    if article.user
      article.user == current_user
    else
      BCrypt::Password.new(article.editing_password_digest).is_password?(cookies[:editing_password])
    end
  end

  def sanitize_with_loofah(content)
    scrubber = Rails::Html::PermitScrubber.new
    scrubber.tags = %w(b i u s strike strong em a ul ol li p br img div span table tr th td figure dd dl dt blockquote h1 h2 h3 h4 h5 h6)
    scrubber.attributes = %w(href style src class)
    unformatted_html = Nokogiri::XML::Node::SaveOptions.class_eval { |m| m::DEFAULT_HTML ^ m::FORMAT }
    Loofah.fragment(content).scrub!(scrubber).to_html(save_with: unformatted_html).html_safe
  end
end
