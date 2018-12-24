namespace :initialize_article_counters do
  desc "Initialize the counter cache of kudos and signal boosts for articles"
  task initialize_counters: :environment do
    Article.find_each do |article|
      Article.reset_counters(article.id,:kudos)
      Article.reset_counters(article.id,:signal_boosts)
    end
  end

end
