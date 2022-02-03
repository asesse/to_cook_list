class Types::Inputs::IngredientQuantityInputType < Types::BaseInputObject
  argument :ingredient_id, ID, required: true
  argument :quantity, Integer, required: true
  argument :unit, Types::Enums::UnitEnumType, required: true
end