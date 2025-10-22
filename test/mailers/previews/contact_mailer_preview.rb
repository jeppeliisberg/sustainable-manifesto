# Preview all emails at http://localhost:3000/rails/mailers/contact_mailer
class ContactMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/contact_mailer/submit_request
  def submit_request
    name = "Jane Doe"
    from_email = "jane@example.com"
    message = "Hello,\n\nI recently signed the manifesto but I need to update my title from 'Software Engineer' to 'Senior Software Engineer'.\n\nCould you please help me with this?\n\nThank you!"

    ContactMailer.submit_request(name, from_email, message)
  end
end
