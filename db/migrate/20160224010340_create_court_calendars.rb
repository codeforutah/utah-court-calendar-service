class CreateCourtCalendars < ActiveRecord::Migration
  def change
    create_table :court_calendars do |t|
      t.integer :court_id, :null => false
      t.text :url, :null => false
      t.datetime :created_at
      t.datetime :modified_at, :null => false
      t.datetime :requested_at
      t.integer :page_count

      #t.timestamps null: false
    end

    add_index :court_calendars, :court_id
    add_index :court_calendars, [:court_id, :url, :modified_at], :unique => true, :name => "calendars_composite_key"
  end
end
