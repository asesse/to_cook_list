class Mutations::CreateRecipe < Mutations::BaseMutation
  argument :name, String, required: true
  argument :instructions, String, required: true
  argument :portions, Integer, required: true
  argument :author_id, ID, required: true, as: :user_id
  argument :ingredients_params, [Types::Inputs::IngredientQuantityInputType, null: false], required: true

  field :recipe, ::Types::RecipeType, null: false 

  def resolve(name:, instructions:, portions:, user_id:, ingredients_params:)
    ActiveRecord::Base.transaction do
      service_result = CreateRecipe.new(
        name: name,
        instructions: instructions,
        portions: portions,
        user_id: user_id,
        ingredients_params: ingredients_params).call
      if service_result[:recipe]
        service_result
      else
        raise GraphQL::ExecutionError.new(service_result[:errors]) 
        ActiveRecord::Rollback
      end
    end
  end
end