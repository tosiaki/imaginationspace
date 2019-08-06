module StatusesHelper
  def quote_if(options={}, &block)
    if options.delete(:comment_present)
      concat content_tag(:div, capture(&block), options)
    else
      concat capture(&block)
    end
  end

  def media_type_class(status)
    if status.post_type == "Article" && status.article.media
      " status-media-" + status.article.media.name.downcase.split("(")[0]
    end
  end
end
