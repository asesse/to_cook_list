class Mutations::CreateUser < Mutations::BaseMutation
  argument :username, String, required: true
  argument :email, String, required: true
  argument :invitation_token, String, required: false

  field :user, ::Types::UserType, null: false 

  def resolve(username:, email:, invitation_token: nil)
    ActiveRecord::Base.transaction do
      service_result = CreateUser.new(
        username: username,
        email: email,
        invitation_token: invitation_token).call
      if service_result[:user]
        service_result
      else
        raise GraphQL::ExecutionError.new(service_result[:errors]) 
        ActiveRecord::Rollback
      end
    end
  end
end