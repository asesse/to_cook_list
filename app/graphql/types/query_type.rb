module Types
  class QueryType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :recipe, Types::RecipeType, null: true do
      argument :id, ID, required: true
    end

    def recipe(id:)
      recipe = Recipe.find_by(id: id)
      raise GraphQL::ExecutionError.new('not_found') if recipe.nil?
      return recipe
    end

    field :recipes, [Types::RecipeType, { null: true }], null: false

    def recipes
      recipes = Recipe.all
    end

    field :user, Types::UserType, null: true do
      argument :id, ID, required: true
    end

    def user(id:)
      user = User.find_by(id: id)
      raise GraphQL::ExecutionError.new('not_found') if user.nil?
      return user
    end
  end
end
