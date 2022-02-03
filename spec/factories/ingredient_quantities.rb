FactoryBot.define do
  factory :ingredient_quantity do 
    association :target, factory: :stock
    association :ingredient
    quantity { rand(1..5) }
    unit { IngredientQuantity::UNITS.sample }
  end 
end