class AddIndexesToSignatures < ActiveRecord::Migration[8.0]
  def change
    add_index :signatures, [ :confirmed_at, :created_at ]
  end
end
