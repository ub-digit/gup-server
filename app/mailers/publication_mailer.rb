class PublicationMailer < ApplicationMailer
  default from: 'noreply.gup@ub.gu.se'
  default to: 'jimmy.carlsson@ub.gu.se'

  def feedback_email(from:, publication_id:, message:)
    @subject = "GUP- Meddelande om pubid: #{publication_id}"
    delivery_options = {address: 'smtp.ub.gu.se:25'}
    mail(subject: @subject, message: message)
  end
end
