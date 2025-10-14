class AddSignedAtToSignatures < ActiveRecord::Migration[8.0]
  def change
    add_column :signatures, :signed_at, :datetime
    add_index :signatures, :signed_at

    # Backfill existing confirmed signatures
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE signatures
          SET signed_at = confirmed_at
          WHERE confirmed_at IS NOT NULL AND signed_at IS NULL
        SQL
      end
    end

    # Update index to use signed_at instead of confirmed_at
    remove_index :signatures, [ :confirmed_at, :created_at ]
    add_index :signatures, [ :signed_at, :created_at ]
  end
end
