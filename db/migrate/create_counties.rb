require_relative "../../app/models.rb"

class CreateCounties < ActiveRecord::Migration
  def change
    create_table :counties do |t|
      t.string :state_postal, :null => false
      t.string :state_fips, :null => false
      t.string :county_fips, :null => false
      t.string :county_name, :null => false
      t.string :fips_class
      t.timestamps
    end

    add_index :counties, :state_postal
    add_index :counties, :state_fips
    add_index :counties, :county_fips
    add_index :counties, :county_name
  end
end

CreateCounties.migrate(:up)
