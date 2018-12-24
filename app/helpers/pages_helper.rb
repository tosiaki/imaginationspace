module PagesHelper
  def page_title(page)
    if page.title.blank?
      "Page #{page.page_number}"
    else
      page.title
    end
  end
end