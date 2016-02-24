class CreateCourts < ActiveRecord::Migration
  def change
    create_table :courts do |t|
      t.string :type, :null => false
      t.string :name, :null => false
      t.text :calendar_url
      t.timestamps null: false
    end

    add_index :courts, :type
    add_index :courts, :name
    add_index :courts, [:type, :name], :unique => true
  end
end
