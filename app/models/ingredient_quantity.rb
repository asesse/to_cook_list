class IngredientQuantity < ApplicationRecord
  UNITS = ['kg', 'g', 'l', 'pcs']
  belongs_to :ingredient
  belongs_to :target, polymorphic: true

  validates :unit, inclusion: { in: UNITS }, allow_blank: false
  validates :ingredient, uniqueness: { scope: :target }
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :target_type, inclusion: { in: [Stock.name, Recipe.name]}, allow_blank: false 
end