class UserChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
		@gathering_id = 0
		@things = {}
		@current_user = current_user
		things.scan_each(match: "#{current_user.id}:*") do |key|
			self.class.broadcast_to current_user, thing: key.split(':')[1],
				amount: things.get(key) 
		end
  end

  def unsubscribed
  end

	def gather(data)
		item = Item.find_by(name: data['gathering'])
		return unless item
		item_gathering = item.gatherings.first
		return unless item_gathering
		action.setnx(current_user.id, 0)
		action.incr(current_user.id)
		thing_key = "#{current_user.id}:#{item.name}"
		things.setnx(thing_key, 0)
		action_id = action.get(current_user.id)
		Thread.new do
			while action_id == action.get(current_user.id)
				sleep poisson(item_gathering.delay)
				if action_id == action.get(current_user.id)
					things.incr(thing_key)
					self.class.broadcast_to current_user, thing: item.name,
						amount: things.get(thing_key) 
				end
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
