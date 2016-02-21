require_relative "../../app/models.rb"

class CreateUtahCourtCalendarPageHeaders < ActiveRecord::Migration
  def change
    create_table :utah_court_calendar_page_headers do |t|
      t.integer :utah_court_calendar_page_id, :null => false
      t.string :jurisdiction
      t.string :judge
      t.text :court_dates
      t.timestamps
    end

    add_index :utah_court_calendar_page_headers, :utah_court_calendar_page_id, :name => "page_index"
  end
end

CreateUtahCourtCalendarPageHeaders.migrate(:up)
