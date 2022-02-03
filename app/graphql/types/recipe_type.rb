class Types::RecipeType < Types::BaseObject
  field :name, String, null: false
  field :instructions, String, null: false
  field :portions, Integer, null: false
  field :author, Types::UserType, null: false
  field :ingredient_quantities, [Types::IngredientQuantityType, null: false], null: false
end