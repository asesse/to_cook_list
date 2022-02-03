class UpdateRecipe

  def initialize(target_id:, params:) # { name: , ingredient_quantities: }
    @target_id = target_id
    @params = params.except(:ingredient_quantities)
    @ingredients_params = params[:ingredient_quantities]
    # @name = name
    # @instructions = instructions
    # @portions = portions
    # @ingredients_params = ingredients_params 
  end

  def call
    ActiveRecord::Base.transaction do 
        @recipe = Recipe.find(@target_id)
        update_recipe!
        { target: @recipe.reload }
      end
  rescue StandardError => e 
    { errors: e.message }
  end

  def update_recipe!
    # recipe = Recipe.find_by(id: @target_id)
    # return { errors: 'not_found' } if recipe.nil?

    # option 1 
    #recipe.update(@params.exclude(:ingredients_params))    # { portions: 2, instructions: nil }

    # option 2 
    @recipe.name = @params[:name]                 if !@params[:name].nil?
    @recipe.portions = @params[:portions]         if !@params[:portions].nil? 
    @recipe.instructions = @params[:instructions] if !@params[:instructions].nil?
    @recipe.save!

    update_ingredient_quantities if @ingredients_params

    # option 3 (when all arguments are required in the mutation)
    # return { errors: recipe.errors.details } unless recipe.update(
    #   name: @name, 
    #   instructions: @instructions, 
    #   portions: @portions)

    # update_ingredient_quantities 
    # return { target: recipe.reload }
  end

  private
    
  def update_ingredient_quantities
    @ingredients_params.each do |ingredient_params|
      if ingredient_params[:quantity] == 0
        destroy_ingredient_quantity(ingredient_params[:ingredient_id])
      else
        update_ingredient_quantity(ingredient_params[:ingredient_id], ingredient_params[:quantity], ingredient_params[:unit])
      end
    end
  end

  def destroy_ingredient_quantity(ingredient_id)
    service_result = DeleteIngredientFromTarget.new(
      target_id: @target_id,
      target_type: 'Recipe',
      ingredient_id: ingredient_id).call
    
    raise Errors::ServiceError.new(message: service_result[:errors]) if service_result[:errors]
  end


  def update_ingredient_quantity(ingredient_id, quantity, unit)
    service_result = UpdateIngredientInTarget.new(
      target_id: @target_id,
      target_type: 'Recipe',
      ingredient_id: ingredient_id,
      ingredient: { quantity: quantity, unit: unit }).call

    raise Errors::ServiceError.new(message: service_result[:errors]) if service_result[:errors]
  end
end
