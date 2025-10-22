require "test_helper"

class SignatureMailerTest < ActionMailer::TestCase
  test "send_confirmation_code sends email with 6-character code" do
    signature = Signature.create!(email: "test@example.com")

    # The verification code is the first 6 characters of the confirmation token
    expected_code = signature.confirmation_token[0, 6]

    email = SignatureMailer.send_confirmation_code(signature)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ "test@example.com" ], email.to
    assert_equal "Your Sustainable Software Manifesto verification code", email.subject
    assert_match expected_code, email.body.encoded
    assert_match "verify your email", email.body.encoded.downcase
  end

  test "verification code is first 6 characters of confirmation token" do
    signature = Signature.create!(email: "test@example.com")

    # Ensure token is at least 6 characters
    assert signature.confirmation_token.length >= 6

    verification_code = signature.confirmation_token[0, 6]
    assert_equal 6, verification_code.length
  end
end
