class SessionController < ApplicationController

  # Create a session, with a newly generated access token
  def create
    @response = {}
    error = nil
    user = User.find_by_username(params[:username])
    if user
      token = user.authenticate(params[:password])
      if token
        @response[:user] = user.as_json
        @response[:access_token] = token
        @response[:token_type] = "bearer"
      else
        error = "Invalid credentials"
      end
    else
      error = "Invalid credentials"
    end
    if error
      render json: {error: { code: "AUTH_ERROR", msg: error}}, status: 401
    else
      render json: @response
    end
  end
  
  def show
    @response = {}
    token = params[:id]
    token_object = AccessToken.find_by_token(token)
    if token_object && token_object.user.validate_token(token)
      @response[:user] = token_object.user.as_json
      @response[:access_token] = token
      @response[:token_type] = "bearer"
      render json: @response
    else
      render json: {error: { code: "SESSION_ERROR", msg: "Invalid session"}}, status: 401
    end
  end
end
