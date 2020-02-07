class GatheringJob < ApplicationJob
  queue_as :default

  def perform(user_id, item)
		user = User.find(user_id)
		item = Item.find_by(name: data['gathering'])
		return unless item
		item_gathering = item.gatherings.first
		return unless item_gathering
		action_id = action.get(user_id)
		action.setnx(user_id, 0)
		action.incr(user_id)
		thing_key = "#{user_id}:#{item.name}"
		things.setnx(thing_key, 0)
		while action_id == action.get(user_id)
			sleep poisson(item_gathering.delay)
			if action_id == action.get(user_id)
				things.incr(thing_key)
				UserChannel.broadcast_to user, thing: item.name,
					amount: things.get(thing_key)
			end
		end
  end

	def poisson(rateParameter)
		-Math.log(1.0 - Random.rand)/rateParameter
	end

	def action
		REDIS_ACTION
	end

	def things
		REDIS_THINGS
	end
end
