require_relative "../../app/models.rb"

class CreateUtahCourtCalendarEvents < ActiveRecord::Migration
  def change
    create_table :utah_court_calendar_events do |t|
      t.integer :utah_court_calendar_id, :null => false

      t.string :court_room
      t.date :date
      t.string :time

      t.string :hearing_type
      t.string :case_number
      t.string :case_type

      t.string :prosecution
      t.string :prosecuting_attorney
      t.string :prosecuting_agency_number
      t.string :defendant
      t.string :defense_attorney

      t.text :defendant_aliases
      t.string :defendant_offender_tracking_number
      t.date :defendant_date_of_birth

      t.text :charges
      t.string :citation_number
      t.string :sheriff_number
      t.string :law_enforcement_agency_number

      t.boolean :case_efiled
      t.boolean :domestic_violence
      t.boolean :warrant_outstanding
      t.string :small_claims_amount

      t.text :page_numbers

      t.timestamps
    end

    add_index :utah_court_calendar_events, :utah_court_calendar_id
    add_index :utah_court_calendar_events, :case_number
    add_index :utah_court_calendar_events, :citation_number
    add_index :utah_court_calendar_events, :sheriff_number
    add_index :utah_court_calendar_events, :law_enforcement_agency_number, :name => "lea_index"
  end
end

CreateUtahCourtCalendarEvents.migrate(:up)
