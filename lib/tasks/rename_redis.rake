namespace :rename_redis do
  desc "Rename the redis keys for action and things"
  task gathering: :environment do
		redis = Redis.new(url: ENV["REDISCLOUD_URL"])
		redis.scan_each(match: "Gathering:*") do |key|
			data = key.split(":")[1]
			redis.rename(key, "action:#{data}")
		end
		redis.scan_each(match: "Things:*") do |key|
			data = key.split(":")[1]
			redis.rename(key, "things:#{data}")
		end
  end

end
