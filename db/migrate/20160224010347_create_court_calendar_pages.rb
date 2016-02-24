class CreateCourtCalendarPages < ActiveRecord::Migration
  def change
    create_table :court_calendar_pages do |t|
      t.integer :court_calendar_id, :null => false
      t.integer :number, :null => false
      t.boolean :parsable
      t.text :parsing_errors
      t.timestamps null: false
    end

    add_index :court_calendar_pages, :court_calendar_id
    add_index :court_calendar_pages, [:court_calendar_id, :number], :unique => true, :name => "pages_composite_key"
  end
end
