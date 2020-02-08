class Preparation < ApplicationRecord
  belongs_to :product, class_name: 'Item'
	has_many :ingredients
end
