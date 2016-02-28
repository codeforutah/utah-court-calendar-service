class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :developer_account_id
      t.string :session_id
      t.string :uuid

      t.string :language
      t.string :ip_address
      t.text :user_agent

      t.text :url
      t.text :referrer
      t.boolean :ssl

      t.timestamps null: false
    end

    add_index :requests, :developer_account_id
    add_index :requests, :session_id
    add_index :requests, :uuid
  end
end
