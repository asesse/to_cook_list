class CreateIngredientQuantityTable < ActiveRecord::Migration[6.1]
  def change
    create_table :ingredient_quantities do |t|
      t.references :ingredient
      t.integer :quantity
      t.string :unit
      t.references :target, polymorphic: true
    end
  end
end
