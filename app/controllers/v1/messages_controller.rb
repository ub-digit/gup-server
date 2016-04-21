class V1::MessagesController < V1::V1Controller

  include PublicationsControllerHelper
  before_filter :find_current_person

  api!
  def create
    message = Message.new(permitted_params)
    message.created_by = @current_user.username
    Message.transaction do
      if message.save
        # Remove old messages
        unless Message.where(message_type: message.message_type).where(deleted_at: nil).where.not(id: message.id).update_all(deleted_at: DateTime.now, deleted_by: @current_user.username)
          raise ActiveRecord::Rollback
        end
        @response[:message] = message
        render_json(201)
        return
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "Message could not be saved", message.errors.messages)
        render_json
        raise ActiveRecord::Rollback
      end

    end
  end

  api!
  def show
    message_type = params[:message_type]
    unless ['NEWS', 'ALERT'].include? message_type
      error_msg(ErrorCodes::REQUEST_ERROR, "No such message type: #{message_type}")
      render_json
      return
    end

    message_query = Message.where(message_type: message_type).where('start_date <= ?', Date.today).where('(end_date IS NULL OR end_date > ?)', Date.today).where(deleted_at: nil)
    message = message_query.first

    if message
      @response[:message] = message
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Currently no valid message for type #{message_type}")
    end

    render_json
  end

  api!
  def destroy
    message_type = params[:message_type]
    unless ['NEWS', 'ALERT'].include? message_type
      error_msg(ErrorCodes::REQUEST_ERROR, "No such message type: #{message_type}")
      render_json
      return
    end

    if Message.where(message_type: message_type).where(deleted_at: nil).update_all(deleted_at: DateTime.now, deleted_by: @current_user.username)
      @response[:message] = 'ok'
    else
      error_msg(ErrorCodes::DELETE_ERROR, "Could not delete messages of type #{message_type}")
    end
    render_json
  end

  private
  def permitted_params
    params.require(:message).permit(:message_type, :start_date, :end_date, :message)
  end

end
