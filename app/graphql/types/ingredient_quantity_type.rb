class Types::IngredientQuantityType < Types::BaseObject
  field :ingredient, Types::IngredientType, null: false
  field :quantity, Integer, null: false
  field :unit, Types::Enums::UnitEnumType, null: false
end