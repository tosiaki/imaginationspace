module ApplicationHelper
  def full_title(title)
    "#{title} | WindyFall"
  end
  
  def tag_contexts 
    ["fandom", "relationship", "character", "tag"]
  end

  def rating_display
    @work.rating.humanize
  end

  def tag_links(context)
    @work.send("#{context}_list").collect { |tag| link_to "#" + tag, send("#{controller_name}_by_tags_path", tag), class: "tag" }.join(", ").html_safe
  end

  def summary_display_links(work)
    all_tags = work.relationship_list.collect do |relationship|
      transient_work_search_button relationship, tags: relationship, class: "summary-relationship tag"
    end
    all_tags += work.character_list.collect do |character|
      transient_work_search_button character, tags: character, class: "tag"
    end
    all_tags += work.tag_list.collect do |tag|
      transient_work_search_button tag, tags: tag, class: "tag"
    end
    all_tags.join(", ").html_safe
  end

  def transient_work_search_button(label, tags:, **options)
    button_to label, works_search_path,
      method: :post,
      params: { tags: tags },
      form: { class: "transient-search-form" },
      **options
  end

  def transient_work_pagination(collection, param_name:)
    return if collection.total_pages <= 1

    current_page = collection.current_page
    controls = []
    controls << transient_work_page_button("Previous", param_name, current_page - 1) if current_page > 1
    controls << content_tag(:span, "Page #{current_page} of #{collection.total_pages}")
    controls << transient_work_page_button("Next", param_name, current_page + 1) if current_page < collection.total_pages
    content_tag(:nav, safe_join(controls), class: "pagination actions", aria: { label: "Search results pages" })
  end

  def transient_work_page_button(label, param_name, page)
    search_params = {
      tags: @search_tags.join(","),
      comics_page: @comics_page,
      drawings_page: @drawings_page
    }.merge(param_name => page)
    button_to label, works_search_path,
      method: :post,
      params: search_params,
      form: { class: "transient-search-form" }
  end

  def display_time_string
    @time_string ||= "%Y-%m-%d"
  end

  def published_display(work)
    work.created_at.strftime(display_time_string)
  end

  def updated_display(work)
    work.page_addition.strftime(display_time_string)
  end

  def outer_date_display(work)
    work.page_addition.strftime("%d %b %Y")
  end

  def updated_or_completed
    if @work.pages == @work.comic_pages.count
      "Completed"
    else
      "Updated"
    end
  end

  def pages_display(comic)
    "#{comic.comic_pages.count}/#{comic.pages > 0 ? comic.pages : '?'}"
  end

  def kudos_display(work)
    sentence = ""
    if work.kudos_giver_users.any?
      sentence += work.kudos_giver_users.map{|user| link_to user.name, user }  .to_sentence
    end
    if work.guest_kudos > 0
      unless sentence.blank?
        sentence += " and "
      end
      sentence += pluralize(work.guest_kudos, "guest")
    end
    sentence += " left kudos on this article!"
  end

  def form_title
    if controller_name == 'drawings'
      object_name = 'fanart'
    else
      object_name = 'fancomic'
    end
    if action_name == 'new' || action_name == 'create'
      "Post new #{object_name}"
    else
      "Edit #{object_name} details"
    end
  end

  def submit_button
    if action_name == 'new' || action_name == 'create'
      'Post'
    else
      'Update'
    end
  end

  def preface_name
    if controller_name == 'drawings'
      "caption"
    else
      "description"
    end
  end

  def display_size_class
    if params[:size]=='small'
      "fit-to-screen"
    else
      "normal-display"
    end
  end

  def thumbnail_image(work)
    if work.class.name == 'Drawing'
      work.drawing.url(:thumb)
    else
      work.comic_pages.first.drawing.url(:thumb)
    end
  end

  def evaluate_adult(work)
    if work.class == Drawing
      modifier = ""
    else
      modifier = "front_"
    end

    if (work.send("#{modifier}explicit?") || work.send("#{modifier}not_rated?")) && !session[:view_adult] && !(user_signed_in? && current_user.show_adult)
      "summary-display gray"
    else
      "summary-display"
    end
  end

  def nav_item(text, path)
    link_to_unless_current(text, path) do
      content_tag 'span', text, class: 'current'
    end
  end

  def get_rating_counts(works,rating)
    works.send(rating).count
  end

  def get_top_tags(works, context, number)
    works.tag_counts_on context, limit: number, order: "count desc"
  end

  def author_link(work)
    if work.authorship == 'scanlation'
      work.author_list.collect { |author| transient_work_search_button(author, tags: author) }.join(", ").html_safe
    else
      link_to work.user.name, work.user
    end
  end

  def work_description(work)
    if work.note.empty?
      "#{@work.title} by #{@work.author}"
    else
      @work.note
    end
  end

  def toggle_size_link(work, size, page = nil)
    if size=='small'
      return show_page_comic_path(@work, page: params[:page]) if page
      return comic_path(@work)
    else
      return show_page_comic_path(@work, page: params[:page], size: 'small') if page
      return comic_path(@work, size: 'small')
    end
  end
end
