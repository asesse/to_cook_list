class UsersController < ApplicationController
  before_action :find_user, only: %i[show destroy update]

  def show
    render json: { errors: 'not_found' }, status: :not_found and return if @user.nil?
  end

  def create
    result = CreateUser.new(username: user_params[:username], email: user_params[:email], invitation_token: params[:invitation_token]).call
    if result[:user]
      @user = result[:user]
      render :show
    else
      render json: { errors: result[:errors][:message] }, status: result[:errors][:status] 
    end
  end

  def update
    render json: { errors: 'user_not_found' }, status: :not_found and return if @user.nil?

    if @user.update(user_params)
        render :show
    else
        render json: { errors: @user.errors.details }, status: :unprocessable_entity
    end
  end

  def destroy
    render json: { errors: 'user_not_found' }, status: :not_found and return if @user.nil?
    render json: { message: 'user_deleted' }, status: 200 if @user.destroy
  end

  private

  def user_params
    params.require(:user).permit(:username, :email)
  end

  def find_user
    @user = User.find_by(id: params[:id])
  end
end

