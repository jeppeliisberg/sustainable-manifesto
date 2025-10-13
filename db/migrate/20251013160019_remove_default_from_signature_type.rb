class RemoveDefaultFromSignatureType < ActiveRecord::Migration[8.0]
  def change
    change_column_default :signatures, :signature_type, from: 0, to: nil
  end
end
