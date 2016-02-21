require_relative "../../app/models.rb"

class CreateUtahCourtCalendarEvents < ActiveRecord::Migration
  def change
    create_table :utah_court_calendar_events do |t|
      t.integer :utah_court_calendar_page_id, :null => false

      t.string :session_start_time

      t.string :hearing_type
      t.string :case_type
      t.string :case_number
      t.string :citation_number
      t.string :sheriff_number
      t.string :lea_number

      t.text :prosecution
      t.string :prosecuting_agency_number
      t.text :prosecutors # attorneys

      t.text :defendants
      t.text :defense_attorneys

      t.text :flags

      t.timestamps
    end

    add_index :utah_court_calendar_events, :utah_court_calendar_id
  end
end

CreateUtahCourtCalendarEvents.migrate(:up)
