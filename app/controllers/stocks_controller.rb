class StocksController < ApplicationController
  before_action :find_stock

  def show
    render json: { errors: 'stock_not_found' }, status: :not_found and return if @stock.nil?
    @ingredient_quantities = @stock.ingredient_quantities.includes(:ingredient)
  end

  private 

  def find_stock
    @stock = Stock.find_by(id: params[:id])
  end
end