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
		GatheringJob.perform_later(current_user.id, data['gathering'])
	end

	def things
		REDIS_THINGS
	end
end
