class CreateStock < ActiveRecord::Migration[6.1]
  def change
    create_table :stocks do |t|
      t.string :invitation_token, unique: true 
      t.timestamps
    end
  end
end
