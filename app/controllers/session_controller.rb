require 'open-uri'

class SessionController < ApplicationController

  # Create a session, with a newly generated access token
  def create
    user_force_authenticated = false

    if params[:cas_ticket] && params[:cas_service]
      username = cas_validate(params[:cas_ticket], params[:cas_service])
      user_force_authenticated = true
      service = :cas
    else
      username = params[:username]
      password = params[:password]
      service = :local
    end

    @response = {}
    error = nil
    user = User.find_by_username(username)
    if !user
      user = User.new(username: username, role: "USER")
    end
    token = user.authenticate(password, user_force_authenticated)
    if token
      @response[:user] = user.as_json
      @response[:access_token] = token
      @response[:token_type] = "bearer"
      render json: @response
    else
      render json: {error: { code: "AUTH_ERROR", msg: error, service: service}}, status: 401
    end
  end
  
  def show
    @response = {}
    token = params[:id]
    token_object = AccessToken.find_by_token(token)
    if token_object && token_object.validated?
      @response[:user] = token_object.user.as_json
      @response[:access_token] = token
      @response[:token_type] = "bearer"
      render json: @response
    else
      render json: {error: { code: "SESSION_ERROR", msg: "Invalid session"}}, status: 401
    end
  end

  private
  def cas_validate(ticket, service)
    casBaseUrl =   Rails.application.config.services[:session][:cas_base_url]
    casParams = {
      service: service,
      ticket: ticket
    }.to_param
    casValidateUrl = "#{casBaseUrl}/serviceValidate?#{casParams}"
    pp ["casValidateUrl", casValidateUrl]
    open(casValidateUrl) do |u| 
      doc = Nokogiri::XML(u.read)
      doc.remove_namespaces!
      pp ["reply", doc.to_xml]
      username = doc.search('//serviceResponse/authenticationSuccess/user').text
      return username if username
    end
  end

end
