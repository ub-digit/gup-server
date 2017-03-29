require 'pp'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :null_session
  before_filter :setup
  before_action :set_locale

  # Setup global state for response
  def setup
    @response ||= {}
  end

  # Renders the response object as json with proper request status
  def render_json(status=200)
    # If successful, render given status
    if @response[:error].nil?
      render json: @response, status: status
    else
      # If not successful, render with status from ErrorCodes module
      render json: @response, status: ErrorCodes.const_get(@response[:error][:code])[:http_status]
    end
  end

  # Generates an error object from code, message and error list
  def error_msg(code=ErrorCodes::ERROR, msg="", error_list = nil)
    @response[:error] = {code: code[:code], msg: msg, errors: error_list}
  end

  private

  # checks if current user has the rights to execute given method
  def validate_rights(right_value)
    validate_access if !@current_user
    if !@current_user.has_right?(right_value)
      error_msg(ErrorCodes::PERMISSION_ERROR, "You don't have the necessary rights (#{right_value}) to perform this action")
      render_json
    end
  end

  # Sets user according to token or api_key, but assign guest instead
  # of returning an authentication error
  def apply_access
    if !validate_token && !validate_key
      @current_user = User.new(username: "GuestUser", role: "GUEST")
    end
  end

  # Sets user according to token or api_key, or authenication error if fail
  def validate_access
    if !validate_token && !validate_key
      error_msg(ErrorCodes::AUTH_ERROR, "User not valid")
      render_json
    end
  end

  # Validates token and sets user if token if valid
  def validate_token
    return false if @current_user
    token = get_token
    token.force_encoding('utf-8') if token
    token_object = AccessToken.find_by_token(token)
    if token_object && token_object.validated?
      @current_user = token_object.user
      return true
    else
      return false
    end
  end

  # Validates given api_key against configurated key and sets user to api_key_user
  def validate_key
    return true if @current_user && @current_user.has_key?
    return false if @current_user
    api_key = params[:api_key]
    api_user = APP_CONFIG['api_key_users'].find{|x| x['api_key'] == api_key}
    if api_user
      api_user = api_user.dup
      api_user.delete('api_key')
      @current_user = User.new(api_user)
      return true
    else
      return false
    end
  end

  # Returns token from request headers or params[:token] if set
  def get_token
    if params.has_key?(:token) && params[:token] != ''
      return params[:token]
    end
    return nil if !request || !request.headers
    token_response = request.headers['Authorization']
    return nil if !token_response
    token_response[/^Token (.*)/,1]
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
