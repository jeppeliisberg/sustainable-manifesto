class SignatureMailer < ApplicationMailer
  default from: "jeppe@sustainablemanifesto.org"

  def send_confirmation_code(signature)
    @signature = signature
    @verification_code = signature.confirmation_token[0, 6]

    mail(
      to: signature.email,
      subject: "Your Sustainable Software Manifesto verification code"
    )
  end
end
