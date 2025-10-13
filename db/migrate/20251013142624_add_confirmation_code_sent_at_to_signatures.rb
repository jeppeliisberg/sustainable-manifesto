class AddConfirmationCodeSentAtToSignatures < ActiveRecord::Migration[8.0]
  def change
    add_column :signatures, :confirmation_code_sent_at, :datetime
  end
end
