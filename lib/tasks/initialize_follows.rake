namespace :initialize_follows do
  desc "Make each user follow self"
  task self_follow: :environment do
    User.all.map(&:subscribe_to_self)
  end

end
