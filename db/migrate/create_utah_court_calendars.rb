require_relative "../../app/models.rb"

class CreateUtahCourtCalendars < ActiveRecord::Migration
  def change
    create_table :utah_court_calendars do |t|
      t.integer :utah_court_id, :null => false
      t.date :court_date, :null => false
      t.text :pdf_url, :null => false
      t.datetime :pdf_created_at
      t.datetime :pdf_modified_at
      t.integer :page_count
      t.timestamps
    end

    add_index :utah_court_calendars, :utah_court_id
    add_index :utah_court_calendars, [:utah_court_id, :pdf_url, :court_date], :unique => true, :name => "ucc_composite_key"
  end
end

CreateUtahCourtCalendars.migrate(:up)
