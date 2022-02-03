class Mutations::DestroyRecipe < Mutations::BaseMutation
  argument :recipe_id, ID, required: true

  field :recipe, ::Types::RecipeType, null: false

  def resolve(recipe_id:)
    service_result = DeleteRecipe.new(target_id: recipe_id).call
    # raise GraphQL::ExecutionError.new('not_found') if service_result.nil?
    raise GraphQL::ExecutionError.new(service_result[:errors]) if service_result[:errors]
    return service_result
  end
end