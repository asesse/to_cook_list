class DeleteRecipe

  def initialize(target_id:)
    @target_id = target_id
  end

  def call
    recipe = Recipe.find_by(id: @target_id)
    return { errors: 'not_found'} if recipe.nil?
    return { errors: recipe.errors.details } unless recipe.destroy
    return { target: recipe }
  end
end