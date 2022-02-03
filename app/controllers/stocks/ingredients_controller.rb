module Stocks
  class IngredientsController < ApplicationController
    def create
      ActiveRecord::Base.transaction do
        service_result = AddIngredientsToTarget.new(target: Stock.find_by(id: params[:stock_id]),
                                                   ingredients_params: params[:ingredients]).call
  
        if service_result[:target]
          @ingredient_quantities = service_result[:target].ingredient_quantities.includes(:ingredient)
          render 'stocks/show'
        else
          render json: service_result, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      end  
    end

    def update
      if params[:ingredient][:quantity] == '0'
        service_result = DeleteIngredientFromTarget.new(target_id: params[:stock_id], 
                                                       target_type: 'Stock', 
                                                       ingredient_id: params[:ingredient_id]).call
      else 
        service_result = UpdateIngredientInTarget.new(target_id: params[:stock_id],
                                                   target_type: 'Stock', 
                                                   ingredient_id: params[:ingredient_id], 
                                                   ingredient: params[:ingredient]).call
      end
                                                 
      if service_result[:target].nil?
       render json: service_result, status: :unprocessable_entity
      else
        @ingredient_quantities = service_result[:target].ingredient_quantities.includes(:ingredient)
        render 'stocks/show'
      end
    end

    def destroy
      service_result = DeleteIngredientFromTarget.new(target_id: params[:stock_id], 
                                                    target_type: 'Stock', 
                                                    ingredient_id: params[:ingredient_id]).call
      if service_result[:target].nil?
        render json: service_result, status: :unprocessable_entity
      else 
        @ingredient_quantities = service_result[:target].ingredient_quantities.includes(:ingredient)
        render 'stocks/show'      
      end
    end
  end
end