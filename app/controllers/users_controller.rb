class UsersController < ApplicationController
  before_filter :fetch_user
  require 'pp'
  
  def index
    @users = User.all
    render json: {users: @users}
  end

  def show
    render json: {user: @user}
  end
  
  def create
    user = User.new(user_params)
    if user.save
      render json: {user: user}
    else
      render json: {error: user.errors }, status: 422
    end
  end

  def update
    if @user.update_attributes(user_params)
      render json: {user: @user}
    else
      render json: {error: @user.errors }, status: 422
    end
  end

  private
  def fetch_user
    if params[:id]
      if params[:id][/^\d+$/]
        @user = User.find_by_id(params[:id])
      else
        @user = User.find_by_username(params[:id])
      end
      if !@user
        error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "users.errors.not_found"}: #{params[:pubid]}")
        render_json
      end
    end
  end

  def user_params
    params.require(:user).permit(:username, :first_name, :last_name, :role)
  end
end
