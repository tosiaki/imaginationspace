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
end
