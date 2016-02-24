class CreateCourtCalendarPageHeaders < ActiveRecord::Migration
  def change
    create_table :court_calendar_page_headers do |t|
      t.integer :court_calendar_page_id, :null => false
      t.string :jurisdiction
      t.string :judge
      t.date :start_date
      t.date :end_date
      t.timestamps null: false
    end

    add_index :court_calendar_page_headers, :court_calendar_page_id, :name => "headers_page_fk"
  end
end
