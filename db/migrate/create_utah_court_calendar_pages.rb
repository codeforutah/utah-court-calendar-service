require_relative "../../app/models.rb"

class CreateUtahCourtCalendarPages < ActiveRecord::Migration
  def change
    create_table :utah_court_calendar_pages do |t|
      t.integer :utah_court_calendar_id, :null => false
      t.integer :number, :null => false
      t.boolean :parsable
      t.text :parsing_errors
      t.timestamps
    end

    add_index :utah_court_calendar_pages, :utah_court_calendar_id
    add_index :utah_court_calendar_pages, [:utah_court_calendar_id, :number], :unique => true, :name => "uccp_composite_key"
  end
end

CreateUtahCourtCalendarPages.migrate(:up)
