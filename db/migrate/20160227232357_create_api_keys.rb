class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.integer :developer_account_id, :null => false
      t.string :secret, :null => false
      t.datetime :revoked_at
      t.timestamps null: false
    end

    add_index :api_keys, :developer_account_id
    add_index :api_keys, :secret, :unique => true
  end
end
