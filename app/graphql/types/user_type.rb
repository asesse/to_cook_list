class Types::UserType < Types::BaseObject
  field :username, String, null: false
  field :email, String, null: false
  field :stock_id, ID, null: false
end