class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  before_filter :validate_token
  protect_from_forgery with: :null_session

  # Validates token and sets user if token if valid
  def validate_token
    return if @current_user
    logger.info "******************* HEJ HEJ **********************"
    token = get_token
    logger.info token.inspect
    token.force_encoding('utf-8') if token
    token_object = AccessToken.find_by_token(token)
    logger.info token_object
    if token_object && token_object.validated?
      @current_user = token_object.user
      logger.info "token valid"
    else
      @current_user = User.new(username: 'api', role: 'USER')
      logger.info "token invalid"
    end
  end

  def get_token
    return nil if !request || !request.headers
    token_response = request.headers['Authorization']
    logger.info token_response.inspect
    return nil if !token_response
    token_response[/^Token (.*)/,1]
  end
end
