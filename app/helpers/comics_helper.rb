module ComicsHelper
  def page_value
    if action_name == 'new'
      "?"
    elsif @comic.pages == 0
      "?"
    else
      @comic.pages
    end
  end
      
end
