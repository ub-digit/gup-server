class PublicationMailer < ActionMailer::Base
  default from: 'noreply.gup@ub.gu.se'
  default to: 'jimmy.carlsson@ub.gu.se'

  def feedback_email(from:, publication_id:, message:)
    @subject = "GUP- Meddelande om pubid: #{publication_id}"
    delivery_options = {address: APP_CONFIG['mail_settings']['delivery_options']['address'], 
                        port: APP_CONFIG['mail_settings']['delivery_options']['port']}

    mail(subject: @subject, 
          body: message,
          content_type:  "text/html",
          delivery_method_options: delivery_options
        )
  end
end
