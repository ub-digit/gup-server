class SessionController < ApplicationController

  # Create a session, with a newly generated access token
  def create
    @response = {}
    error = nil
    user = User.find_by_username(params[:username])
    if !user
      user = User.new(username: params[:username], role: "USER")
    end
    token = user.authenticate(params[:password])
    if token
      @response[:user] = user.as_json
      @response[:user][:role] = user.role_data
      @response[:access_token] = token
      @response[:token_type] = "bearer"
      render json: @response
    else
      render json: {error: { code: "AUTH_ERROR", msg: error}}, status: 401
    end
  end
  
  def show
    @response = {}
    token = params[:id]
    token_object = AccessToken.find_by_token(token)
    if token_object && token_object.validated?
      @response[:user] = token_object.user.as_json
      @response[:user][:role] = token_object.user.role_data
      @response[:access_token] = token
      @response[:token_type] = "bearer"
      render json: @response
    else
      render json: {error: { code: "SESSION_ERROR", msg: "Invalid session"}}, status: 401
    end
  end
end
