class Mutations::UpdateRecipe < Mutations::BaseMutation
  argument :recipe_id, ID, required: true
  argument :name, String, required: false
  argument :instructions, String, required: false
  argument :portions, Integer, required: false
  argument :ingredient_quantities, [Types::Inputs::IngredientQuantityInputType, null: false], required: false

  field :recipe, ::Types::RecipeType, null: false 
 
  def resolve(**args)
    service_result = UpdateRecipe.new(target_id: args[:recipe_id], params: args.to_h.except(:recipe_id)).call
    
    # service_result = UpdateRecipe.new(
    #   target_id: args[:recipe_id],
    #   name: args[:name], 
    #   instructions: args[:instructions],
    #   portions: args[:portions],
    #   ingredients_params: args[:ingredient_quantities].map(&:to_h)).call
    
    if service_result[:target] # { target: recipe }
      { recipe: service_result[:target] }
    else 
      GraphQL::ExecutionError.new(service_result[:errors])
    end
  end
end


