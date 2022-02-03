class IncrementQuantityToExistingIngredient

  def initialize(target_id:, target_type:, ingredient_params:)
    @target_id = target_id
    @target_type = target_type
    @ingredient_params = ingredient_params
  end

  def call
    ingredient_quantity = IngredientQuantity.find_by(target_id: @target_id,
                                                     target_type: @target_type,
                                                     ingredient_id: @ingredient_params[:ingredient_id])
                                                   
    return { errors: 'resource_not_found' } if ingredient_quantity.nil?
    return { errors: ingredient_quantity.errors.details } unless increment_quantity(ingredient_quantity, @ingredient_params[:quantity].to_i)  
    return { target: ingredient_quantity.target }
  end

  private

  def increment_quantity(ingredient_quantity, added_quantity)
    existing_quantity = ingredient_quantity.quantity
    ingredient_quantity.update(quantity: existing_quantity + added_quantity)
  end
end