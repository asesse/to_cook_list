class AddStockToUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :stock, foreign_key: true
  end
end

