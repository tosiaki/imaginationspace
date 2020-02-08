class Ingredient < ApplicationRecord
  belongs_to :preparation
  belongs_to :item
end
