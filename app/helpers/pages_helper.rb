module PagesHelper
  def page_title(page)
    if page.title.blank?
      "Page #{page.page_number}"
    else
      page.title
    end
  end

  def head_title(article, page)
    [article.title,page.title,article.authored_by].reject{|e| e.blank?}.join(' - ').html_safe
  end

  def full_title_article(article,page)
    full_title head_title(article,page)
  end
end