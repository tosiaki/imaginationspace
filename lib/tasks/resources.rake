namespace :resources do
  desc "Create the first resources and gatherings"
  task make_first: :environment do
		green_onion = Item.create(name: "Green onion")
		tuna = Item.create(name: "Tuna")
		Gathering.create(item: green_onion, delay: 1.5)
		Gathering.create(item: tuna, delay: 1.5)
  end

end
