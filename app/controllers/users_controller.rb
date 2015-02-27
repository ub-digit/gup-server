class UsersController < ApplicationController
  def create
    user = User.new(user_params)
    if user.save
      render json: {user: user}
    else
      render json: {error: user.errors }, status: 422
    end
  end

  def update
    user = User.find_by_id(params[:id])
    if user
      if user.update_attributes(user_params)
        render json: {user: user}
      else
        render json: {error: user.errors }, status: 422
      end
    else
      render json: {error: "Not Found"}, status: 404
    end
  end

  private
  def user_params
    params.require(:user).permit(:username, :first_name, :last_name, :role)
  end
end
