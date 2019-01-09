module TagsHelper
  def tags_heading(tags)
    tags.map do |tag|
      link_to(tag, articles_path(tags: tag), class: 'tag') + " " +
      link_to('❌', url_for(tags: (tags-[tag]).join(',')), class: 'remove-tag')
    end.join(', ').html_safe
  end
end