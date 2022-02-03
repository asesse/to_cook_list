class CreateRecipe < ActiveRecord::Migration[6.1]
  def change
    create_table :recipes do |t|
      t.string :name
      t.text :instructions
      t.integer :portions
      t.references :user

      t.timestamps
    end
  end
end
