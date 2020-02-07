REDIS_ACTION = Redis::Namespace.new(:action, redis: Redis.new(url: ENV["REDISCLOUD_URL"]))
REDIS_THINGS = Redis::Namespace.new(:things, redis: Redis.new(url: ENV["REDISCLOUD_URL"]))
