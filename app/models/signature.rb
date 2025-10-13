class Signature < ApplicationRecord
  enum :signature_type, { individual: 0, organization: 1 }

  encrypts :email, deterministic: true # Deterministic allows for unique index lookups

  has_secure_token :confirmation_token

  validates :email, presence: true, uniqueness: true
  validate :organization_domain_uniqueness, if: :organization?

  def confirmed?
    confirmed_at.present?
  end

  def can_resend_code?
    confirmation_code_sent_at.nil? || confirmation_code_sent_at < 1.minute.ago
  end

  def send_confirmation_code!
    regenerate_confirmation_token
    update(confirmation_code_sent_at: Time.current)
    SignatureMailer.send_confirmation_code(self).deliver_later
  end

  def email_domain
    return nil if email.blank?
    email.split("@").last
  end

  private

  def organization_domain_uniqueness
    return if email.blank? || !organization?

    domain = email_domain
    existing = Signature.where(signature_type: :organization)
                       .where.not(id: id)
                       .find { |sig| sig.email_domain == domain && sig.confirmed? }

    if existing
      errors.add(:email, "Your organization has already signed the manifesto.")
    end
  end
end
