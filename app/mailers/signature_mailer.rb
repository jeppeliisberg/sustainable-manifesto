class SignatureMailer < ApplicationMailer
  default from: "noreply@sustainablemanifesto.org"

  def send_confirmation_code(signature)
    @signature = signature
    @verification_code = signature.confirmation_token[0, 6]

    mail(
      to: signature.email,
      subject: "Verify your email for Sustainable Software Manifesto"
    )
  end
end
