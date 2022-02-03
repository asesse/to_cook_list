class UpdateIngredientInTarget
  def initialize(target_id:, target_type:, ingredient_id:, ingredient:)
    @target_id = target_id
    @target_type = target_type
    @ingredient_id = ingredient_id
    @ingredient = ingredient 
  end

  def call
    ingredient_quantity = IngredientQuantity.find_by(target_id: @target_id, 
                                                     target_type: @target_type,
                                                     ingredient_id: @ingredient_id)
                                                     
    if ingredient_quantity.nil?
      return { errors: 'resource_not_found' }
    elsif ingredient_quantity.update(quantity: @ingredient[:quantity], unit: @ingredient[:unit])
      return { target: ingredient_quantity.target }
    else
      return { errors: ingredient_quantity.errors.details }
    end
  end

  # def call
  #   ActiveRecord::Base.transaction do 
  #     ingredient_quantity = IngredientQuantity.find_by!(target_id: @target_id, 
  #                                                       target_type: @target_type,
  #                                                       ingredient_id: @ingredient_id)
      
  #     ingredient_quantity.update!(quantity: @ingredient[:quantity], unit: @ingredient[:unit])
      
  #     { target: ingredient_quantity.target }
  #   rescue StandardError => e 
  #     ActiveRecord::Rollback
  #     { errors: e.message }
  #   end
  # end
end