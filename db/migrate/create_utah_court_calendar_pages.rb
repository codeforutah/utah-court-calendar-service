require_relative "../../app/models.rb"

class CreateUtahCourtCalendarPages < ActiveRecord::Migration
  def change
    create_table :utah_court_calendar_pages do |t|
      t.integer :utah_court_calendar_id, :null => false
      t.string :jurisdiction, :null => false
      t.integer :number, :null => false

      t.string :court_day, :null => false
      t.string :court_date, :null => false

      t.string :judge_name
      t.string :court_room

      t.timestamps
    end

    add_index :utah_court_calendar_pages, :utah_court_calendar_id
  end
end

CreateUtahCourtCalendarPages.migrate(:up)
