class V1::FeedbackMailsController < V1::V1Controller

  def create
    mail_params = params[:feedback_mail]
    if !mail_params.has_key?(:from) || !mail_params.has_key?(:message) || !mail_params.has_key?(:publication_id) 
      error_msg(ErrorCodes::REQUEST_ERROR, "Missing parameters") 
      render_json 
      return 
    end 
    mail_params[:from] = @current_user.username
    if PublicationMailer.feedback_email(message: mail_params[:message], publication_id: mail_params[:publication_id], from: mail_params[:from]).deliver_now 
      @response[:feedback_mail] = {}
      @response[:feedback_mail][:status] = "ok" 
      render_json
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not send email")
      render_json
    end
  end
end
