require_relative "../../app/models.rb"

class CreateUtahCourtCalendars < ActiveRecord::Migration
  def change
    create_table :utah_court_calendars do |t|
      t.integer :utah_court_id, :null => false
      t.text :url, :null => false
      t.datetime :created_at
      t.datetime :modified_at, :null => false
      t.datetime :requested_at
      t.integer :page_count
      #t.timestamps
    end

    add_index :utah_court_calendars, :utah_court_id
    add_index :utah_court_calendars, [:utah_court_id, :url, :modified_at], :unique => true, :name => "ucc_composite_key"
  end
end

CreateUtahCourtCalendars.migrate(:up)
