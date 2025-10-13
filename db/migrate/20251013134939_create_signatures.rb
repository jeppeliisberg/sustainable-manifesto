class CreateSignatures < ActiveRecord::Migration[8.0]
  def change
    create_table :signatures do |t|
      t.string :name
      t.string :email, null: false
      t.string :title
      t.string :organization
      t.string :profile_url
      t.integer :signature_type, default: 0 # 0 for individual, 1 for organization
      t.string :confirmation_token, null: false, index: { unique: true }
      t.datetime :confirmed_at

      t.timestamps
    end

    add_index :signatures, :email, unique: true
  end
end
