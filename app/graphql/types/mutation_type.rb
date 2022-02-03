module Types
  class MutationType < Types::BaseObject
    field :create_recipe, mutation: ::Mutations::CreateRecipe
    field :update_recipe, mutation: ::Mutations::UpdateRecipe
    field :destroy_recipe, mutation: ::Mutations::DestroyRecipe
    field :create_user, mutation: ::Mutations::CreateUser
  end
end
