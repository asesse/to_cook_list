class CreateRecipe

  def initialize(name:, instructions:, portions:, user_id:, ingredients_params:)
    @name = name
    @instructions = instructions
    @portions = portions
    @user_id = user_id
    @ingredients_params = ingredients_params
  end

  def call
    recipe = Recipe.new(
      name: @name,
      instructions: @instructions,
      portions: @portions,
      user_id: @user_id)
    
    if recipe.save
      add_ingredient_to_target = AddIngredientsToTarget.new(target: recipe,
                                                            ingredients_params: @ingredients_params).call
      return add_ingredient_to_target unless  add_ingredient_to_target[:target]
      return { recipe: recipe }
    else 
      return { errors: recipe.errors.details } 
    end
  end
end