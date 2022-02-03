class DeleteIngredientFromTarget

  def initialize(target_id:, target_type:, ingredient_id:)
    @target_id = target_id
    @target_type = target_type
    @ingredient_id = ingredient_id
  end

  def call
    ingredient_quantity = IngredientQuantity.find_by(target_id: @target_id, 
                                                    target_type: @target_type,
                                                    ingredient_id: @ingredient_id)
      return { errors: 'resource_not_found'} if ingredient_quantity.nil?
      return { target: ingredient_quantity.target } if ingredient_quantity.destroy
      return { errors: ingredient_quantity.errors.details } 
  end
end