class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  before_filter :validate_token
  protect_from_forgery with: :null_session
  before_filter :setup

  # Validates token and sets user if token if valid
  def validate_token
    return if @current_user
    token = get_token
    token.force_encoding('utf-8') if token
    token_object = AccessToken.find_by_token(token)
    if token_object && token_object.validated?
      @current_user = token_object.user
      logger.info "ApplicationController.validate_token() => \"token valid\""
    else
      @current_user = User.new(username: 'api', role: 'USER')
      logger.info "ApplicationController.validate_token() => \"token invalid\""
    end
  end

  def get_token
    return nil if !request || !request.headers
    token_response = request.headers['Authorization']
    return nil if !token_response
    token_response[/^Token (.*)/,1]
  end

  # Setup global state for response
  def setup
    @response ||= {}
  end

  def render_json(status = 200)
    # If successful, render object as JSON
    if @response[:error].nil?
      render json: @response, status: status
    else
      # If not successful, render error as JSON
      render json: @response, status: @response[:error][:code]
    end
  end

  # Generates an error object from code, message and error list
  # If the msg parameter is not provided the HTTP_STATUS message will be used.
  # If no specific HTTP Coce is given then 400, Bad Request will be used.
  def generate_error(http_code = 422, msg = "", error_list = nil)

    if msg == ""
      msg = code_to_message(http_code)
    end
    @response = {}
    @response[:error] = {code: http_code, msg: msg, errors: error_list}
  end

  def code_to_message(http_code = 422)
    Rack::Utils::HTTP_STATUS_CODES[http_code]
  end
end
