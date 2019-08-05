namespace :initialize_threads do
  desc "Seat each post's thread_origin field"
  task set_origin: :environment do
    Article.find_each do |a|
      a.update_attribute(:thread, origin_of(a))
    end
  end

  def origin_of(article)
    if article.reply_to
      origin_of(article.reply_to)
    else
      article
    end
  end
end
