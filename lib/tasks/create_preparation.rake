namespace :create_preparation do
  desc "Create the first preparation"
  task first: :environment do
		negitoro = Item.create(name: "Negitoro")
		preparation = Preparation.create(name: "Negitoro", product: negitoro, time_required: 2)
		Ingredient.create(preparation: preparation, item: Item.find_by(name: "Green onion"))
		Ingredient.create(preparation: preparation, item: Item.find_by(name: "Tuna"))
  end

end
