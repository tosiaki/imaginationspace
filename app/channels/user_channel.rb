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
		gathering.setnx(current_user.id, 0)
		gathering.incr(current_user.id)
		thing_key = "#{current_user.id}:#{item.name}"
		things.setnx(thing_key, 0)
		gathering_id = gathering.get(current_user.id)
		Thread.new do
			while gathering_id == gathering.get(current_user.id)
				sleep item_gathering.delay
				if gathering_id == gathering.get(current_user.id)
					things.incr(thing_key)
					self.class.broadcast_to current_user, thing: item.name,
						amount: things.get(thing_key) 
				end
			end
		end
	end

	def gathering
		REDIS_GATHERING
	end

	def things
		REDIS_THINGS
	end
end
