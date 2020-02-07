class GatheringJob < ApplicationJob
  queue_as :default

  def perform(user_id, item_name)
		user = User.find(user_id)
		item = Item.find_by(name: item_name)
		return unless item
		item_gathering = item.gatherings.first
		return unless item_gathering
		action.setnx(user_id, 0)
		action.incr(user_id)
		thing_key = "#{user_id}:#{item_name}"
		things.setnx(thing_key, 0)
		action_id = action.get(user_id)
		while action_id == action.get(user_id)
			sleep poisson(item_gathering.delay)
			if action_id == action.get(user_id)
				things.incr(thing_key)
				UserChannel.broadcast_to user, thing: item_name,
					amount: things.get(thing_key)
			end
		end
  end

	def poisson(delay)
		-Math.log(1.0 - Random.rand)*delay
	end

	def action
		REDIS_ACTION
	end

	def things
		REDIS_THINGS
	end
end
