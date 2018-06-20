module ApplicationHelper
  def rating_display(object)
    object.rating.humanize
  end

  def fandom_links(object)
    object.fandom_list.collect { |fandom| link_to fandom, drawings_by_tags_path(fandom) }.join(", ").html_safe
  end

  def relationship_links(object)
    object.relationship_list.collect { |relationship| link_to relationship, drawings_by_tags_path(relationship) }.join(", ").html_safe
  end

  def character_links(object)
    object.character_list.collect { |character| link_to character, drawings_by_tags_path(character) }.join(", ").html_safe
  end

  def tag_links(object)
    object.tag_list.collect { |tag| link_to tag, drawings_by_tags_path(tag) }.join(", ").html_safe
  end

  def published_display(object)
    object.created_at.strftime("%Y-%m-%d")
  end

  def pages_display(object)
    "#{@comic.comic_pages.count}/#{@comic.pages > 0 ? @comic.pages : '?'}"
  end

  def form_title
    if controller_name == 'drawings'
      object_name = 'fanart'
    else
      object_name = 'fancomic'
    end
    if action_name == 'new'
      "Post new #{object_name}"
    else
      "Edit #{object_name} details"
    end
  end

  def submit_button
    if params[:action] == 'new'
      'Post'
    else
      'Update'
    end
  end
end
