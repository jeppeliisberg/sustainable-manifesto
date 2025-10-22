class ContactMailer < ApplicationMailer
  default from: "jeppe@sustainablemanifesto.org" # Match existing mailer

  def submit_request(name, from_email, message)
    @name = name
    @from_email = from_email
    @message_content = message

    mail(
      to: Rails.application.credentials.dig(:contact_form_recipient),
      reply_to: @from_email,
      subject: "New Manifesto Contact Form Submission from #{@name}"
    )
  end
end
