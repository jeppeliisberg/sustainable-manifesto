# Preview all emails at http://localhost:3000/rails/mailers/signature_mailer
class SignatureMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/signature_mailer/send_confirmation_code
  def send_confirmation_code
    signature = Signature.last || create_sample_signature
    SignatureMailer.send_confirmation_code(signature)
  end

  private

  def create_sample_signature
    Signature.new(
      email: "test@example.com",
      name: "Jane Doe",
      signature_type: :individual,
      title: "Software Engineer",
      organization: "Acme Corp",
      profile_url: "https://github.com/janedoe",
      confirmation_token: SecureRandom.alphanumeric(32)
    )
  end
end
