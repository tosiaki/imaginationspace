namespace :create_finding do
  desc "Create the first findings"
  task first: :environment do
		Finding.create(thing_name: "Grain", required_experience: 0, scarcity: 4)
		Finding.create(thing_name: "Carrot", required_experience: 0, scarcity: 4)
		Finding.create(thing_name: "Ruby", required_experience: 1000, scarcity: 15)
		Finding.create(thing_name: "Emerald", required_experience: 1000, scarcity: 15)
  end

end
