require "test_helper"

class SignatureTest < ActiveSupport::TestCase
  test "creates signature with valid email" do
    signature = Signature.create(email: "test@example.com")
    assert signature.persisted?
    assert_equal "test@example.com", signature.email
  end

  test "requires email presence" do
    signature = Signature.new(email: nil)
    assert_not signature.valid?
    assert_includes signature.errors[:email], "can't be blank"
  end

  test "requires unique email" do
    Signature.create!(email: "test@example.com")
    duplicate = Signature.new(email: "test@example.com")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "generates confirmation_token automatically" do
    signature = Signature.create(email: "test@example.com")
    assert_not_nil signature.confirmation_token
    assert_equal 24, signature.confirmation_token.length
  end

  test "signature_type is nil by default" do
    signature = Signature.create(email: "test@example.com")
    assert_nil signature.signature_type
  end

  test "can be individual signature_type" do
    signature = Signature.create(email: "test@example.com", signature_type: :individual)
    assert signature.individual?
    assert_equal "individual", signature.signature_type
  end

  test "can be organization signature_type" do
    signature = Signature.create(email: "test@example.com", signature_type: :organization)
    assert signature.organization?
    assert_equal "organization", signature.signature_type
  end

  test "confirmed? returns false when confirmed_at is nil" do
    signature = Signature.create(email: "test@example.com")
    assert_not signature.confirmed?
  end

  test "confirmed? returns true when confirmed_at is set" do
    signature = Signature.create(email: "test@example.com", confirmed_at: Time.current)
    assert signature.confirmed?
  end

  test "encrypts email attribute" do
    signature = Signature.create(email: "test@example.com")
    # The email should be encrypted in the database
    raw_email_value = ActiveRecord::Base.connection.execute(
      "SELECT email FROM signatures WHERE id = #{signature.id}"
    ).first["email"]

    # Encrypted value should not equal plain text
    assert_not_equal "test@example.com", raw_email_value

    # But accessing through the model should return decrypted value
    assert_equal "test@example.com", signature.reload.email
  end

  test "can_resend_code? returns true when confirmation_code_sent_at is nil" do
    signature = Signature.create(email: "test@example.com")
    assert signature.can_resend_code?
  end

  test "can_resend_code? returns false when code was sent less than 1 minute ago" do
    signature = Signature.create(email: "test@example.com", confirmation_code_sent_at: 30.seconds.ago)
    assert_not signature.can_resend_code?
  end

  test "can_resend_code? returns true when code was sent more than 1 minute ago" do
    signature = Signature.create(email: "test@example.com", confirmation_code_sent_at: 2.minutes.ago)
    assert signature.can_resend_code?
  end

  test "email_domain extracts domain from email" do
    signature = Signature.create(email: "user@example.com")
    assert_equal "example.com", signature.email_domain
  end

  test "organization domain uniqueness allows individual signatures from same domain" do
    Signature.create!(email: "user1@example.com", signature_type: :individual, confirmed_at: Time.current)
    signature2 = Signature.new(email: "user2@example.com", signature_type: :individual)
    assert signature2.valid?
  end

  test "organization domain uniqueness allows unconfirmed organization from same domain" do
    Signature.create!(email: "org1@example.com", signature_type: :organization)
    signature2 = Signature.new(email: "org2@example.com", signature_type: :organization)
    assert signature2.valid?
  end

  test "organization domain uniqueness prevents confirmed organization from same domain" do
    Signature.create!(email: "org1@example.com", signature_type: :organization, confirmed_at: Time.current)
    signature2 = Signature.new(email: "org2@example.com", signature_type: :organization)
    assert_not signature2.valid?
    assert_includes signature2.errors[:email], "Your organization has already signed the manifesto."
  end

  test "organization domain uniqueness allows different domains" do
    Signature.create!(email: "org@example.com", signature_type: :organization, confirmed_at: Time.current)
    signature2 = Signature.new(email: "org@different.com", signature_type: :organization)
    assert signature2.valid?
  end

  test "organization domain uniqueness allows updating existing organization" do
    signature = Signature.create!(email: "org@example.com", signature_type: :organization, confirmed_at: Time.current)
    signature.name = "Updated Name"
    assert signature.valid?
  end
end
