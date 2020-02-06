REDIS_GATHERING = Redis::Namespace.new("Gathering", redis: Redis.new(url: ENV["REDISCLOUD_URL"]))
REDIS_THINGS = Redis::Namespace.new("Things", redis: Redis.new(url: ENV["REDISCLOUD_URL"]))
