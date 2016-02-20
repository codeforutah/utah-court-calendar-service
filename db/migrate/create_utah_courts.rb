require_relative "../../app/models.rb"

class CreateUtahCourts < ActiveRecord::Migration
  def change
    create_table :utah_courts do |t|
      t.string :type, :null => false
      t.string :name, :null => false
      t.text :calendar_url
      t.timestamps
    end

    add_index :utah_courts, :type
    add_index :utah_courts, :name
    add_index :utah_courts, [:type, :name], :unique => true
  end
end

CreateUtahCourts.migrate(:up)
