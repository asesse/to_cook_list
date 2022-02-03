class CreateUser
  def initialize(username:, email:, invitation_token: nil)
    @username = username
    @email = email
    @invitation_token = invitation_token
  end

  def call
    if @invitation_token
      stock = Stock.find_by(invitation_token: @invitation_token)
    else
      stock = Stock.new
    end

    user = User.new(username: @username, email: @email, stock: stock)
    if user.save
      return { user: user, stock: stock }
    else
      return { errors: { message: user.errors.details, status: :unprocessable_entity } }
    end
  end
end