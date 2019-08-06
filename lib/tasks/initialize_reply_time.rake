namespace :initialize_reply_time do
  desc "Initilize the reply_time values"
  task update_data: :environment do
    Article.find_each do |a|
      if a.thread_id==a.id
        a.update_attribute(:reply_time, find_reply_time(a))
      else
        a.update_attribute(:reply_time, a.created_at)
      end
    end
  end

  def find_reply_time(article)
    result = article.thread_posts.order(created_at: :desc).limit(1)
    result.first.created_at
  end
end
