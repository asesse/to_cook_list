class AddIndexToInvitationTokenInStock < ActiveRecord::Migration[6.1]
  def change
    add_index :stocks, :invitation_token, unique: true
  end
end
