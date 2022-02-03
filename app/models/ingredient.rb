class Ingredient < ApplicationRecord
  has_many :ingredient_quantities
  validates :name, presence: true, uniqueness: true
end