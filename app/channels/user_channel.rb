class UserChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
		@gathering_id = 0
		@things = {}
		@current_user = current_user
		things.scan_each(match: "#{current_user.id}:*") do |key|
			self.class.broadcast_to current_user, action: 'setup', thing: key.split(':')[1],
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
					self.class.broadcast_to current_user, action: 'gather', thing: item.name,
						amount: things.get(thing_key) 
				end
			end
		end
	end

	def prepare(data)
		preparation = Preparation.find_by(name: data['prepare'])
		return unless preparation
		item = preparation.product
		action.setnx(current_user.id, 0)
		action.incr(current_user.id)
		thing_key = "#{current_user.id}:#{item.name}"
		things.setnx(thing_key, 0)
		action_id = action.get(current_user.id)
		Thread.new do
			while has_ingredients(preparation) && action_id == action.get(current_user.id)
				sleep pert(preparation.time_required*0.8, preparation.time_required, preparation.time_required*2)
				if action_id == action.get(current_user.id)
					things.incr(thing_key)
					remove_ingredients(preparation)
					self.class.broadcast_to current_user, action: 'prepare', thing: item.name,
						amount: things.get(thing_key)
				end
			end
		end
	end

	def explore(data)
		action.setnx(current_user.id, 0)
		action.incr(current_user.id)
		action_id = action.get(current_user.id)
		exploring.setnx(current_user.id, 0)
		Finding.all.each do |finding|
			find_thing(finding, action_id)
		end
		next_finding_exp = get_next_finding_exp
		Thread.new do
			while action_id == action.get(current_user.id) && negitoro_amount > 0
				sleep 1.5
				if action_id == action.get(current_user.id)
					exploring.incr(current_user.id)
					things.decr(negitoro_key)
					self.class.broadcast_to current_user, action: 'expend', thing: "Negitoro", amount: negitoro_amount
					if exploring.get(current_user.id).to_i >= next_finding_exp
						findings = Finding.find_by(required_experience: next_finding_experience)
						findings.each do |finding|
							find_thing(finding, action_id)
						end
						next_finding_exp = get_next_finding_exp
					end
				end
			end
		end
	end

	def find_thing(finding, action_id)
		if finding.required_experience <= exploring.get(current_user.id).to_i
			Thread.new do
				while action_id == action.get(current_user.id) && negitoro_amount > 0
					sleep poisson(finding.scarcity)
					if action_id == action.get(current_user.id) && negitoro_amount > 0
						thing_key = "#{current_user.id}:#{finding.thing_name}"
						things.incr(thing_key)
						self.class.broadcast_to current_user, action: 'gather', thing: finding.thing_name, amount: things.get(thing_key)
					end
				end
			end
		end
	end

	def get_next_finding_exp
		finding = Finding.where("required_experience > ?", exploring.get(current_user.id)).order(:required_experience).first
		if finding
			finding.required_experience
		else
			Float::INFINITY
		end
	end

	def negitoro_key
		"#{current_user.id}:Negitoro"
	end

	def negitoro_amount
		things.get(negitoro_key).to_i
	end

	def has_ingredients(preparation)
		preparation.ingredients.each do |ingredient|
			amount = things.get("#{current_user.id}:#{ingredient.item.name}").to_i
			unless amount > 0
				return false
			end
		end
		return true
	end

	def remove_ingredients(preparation)
		preparation.ingredients.each do |ingredient|
			thing_key = "#{current_user.id}:#{ingredient.item.name}"
			things.decr(thing_key)
			self.class.broadcast_to current_user, action: 'expend', thing: ingredient.item.name,
				amount: things.get(thing_key)
		end
	end

	def pert(low, likely, high)
		average = (low + 4.0*likely+high)/6.0
		alpha = (average-low)*(2.0*likely-low-high)/((likely-average)*(high-low))
		beta = alpha*(high-average)/(average-low)
		beta(alpha, beta)*(high-low)+low
	end

	def beta(alpha, beta)
		y1 = 1
		y2 = 1
		until y1 + y2 <= 1
			y1 = Random.rand ** (1.0/alpha)
			y2 = Random.rand ** (1.0/beta)
		end

		y1/(y1+y2)
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

	def exploring
		REDIS_EXPLORING
	end
end
