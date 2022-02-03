class AddIngredientsToTarget
  def initialize(target:, ingredients_params:)
    @target = target
    @ingredients_params = ingredients_params
  end

  def call
    return { errors: 'resource_not_found' } if @target.nil?
    @ingredients_params.each do |ingredient_params| 
      if @target.ingredients.ids.include?(ingredient_params[:ingredient_id].to_i) 
        service_result = IncrementQuantityToExistingIngredient.new(target_id: @target.id,
                                                                   target_type: @target.class.name,
                                                                   ingredient_params: ingredient_params).call
        return service_result if service_result[:errors]

        else
          ingredient_quantity = IngredientQuantity.new(target_id: @target.id,
                                                     target_type: @target.class.name, 
                                                     ingredient_id: ingredient_params[:ingredient_id],
                                                     quantity: ingredient_params[:quantity], 
                                                     unit: ingredient_params[:unit])
        return { errors: ingredient_quantity.errors.details }  unless ingredient_quantity.save 
      end           
   end
  
    return { target: @target }
    
  end
end