# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160227232357) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.integer  "developer_account_id", null: false
    t.string   "secret",               null: false
    t.datetime "revoked_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "api_keys", ["developer_account_id"], name: "index_api_keys_on_developer_account_id", using: :btree
  add_index "api_keys", ["secret"], name: "index_api_keys_on_secret", unique: true, using: :btree

  create_table "counties", force: :cascade do |t|
    t.string   "state_postal", null: false
    t.string   "state_fips",   null: false
    t.string   "county_fips",  null: false
    t.string   "county_name",  null: false
    t.string   "fips_class"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "counties", ["county_fips"], name: "index_counties_on_county_fips", using: :btree
  add_index "counties", ["county_name"], name: "index_counties_on_county_name", using: :btree
  add_index "counties", ["state_fips"], name: "index_counties_on_state_fips", using: :btree
  add_index "counties", ["state_postal"], name: "index_counties_on_state_postal", using: :btree

  create_table "court_calendar_events", force: :cascade do |t|
    t.integer  "court_calendar_id",                  null: false
    t.integer  "first_page_id",                      null: false
    t.string   "court_room"
    t.date     "date"
    t.string   "time"
    t.string   "hearing_type"
    t.string   "case_number"
    t.string   "case_type"
    t.string   "prosecution"
    t.string   "prosecuting_attorney"
    t.string   "prosecuting_agency_number"
    t.string   "defendant"
    t.string   "defense_attorney"
    t.text     "defendant_aliases"
    t.string   "defendant_offender_tracking_number"
    t.date     "defendant_date_of_birth"
    t.text     "charges"
    t.string   "citation_number"
    t.string   "sheriff_number"
    t.string   "law_enforcement_agency_number"
    t.boolean  "case_efiled"
    t.boolean  "domestic_violence"
    t.boolean  "warrant_outstanding"
    t.string   "small_claims_amount"
    t.text     "page_numbers"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "court_calendar_events", ["case_number"], name: "index_court_calendar_events_on_case_number", using: :btree
  add_index "court_calendar_events", ["citation_number"], name: "index_court_calendar_events_on_citation_number", using: :btree
  add_index "court_calendar_events", ["court_calendar_id"], name: "index_court_calendar_events_on_court_calendar_id", using: :btree
  add_index "court_calendar_events", ["law_enforcement_agency_number"], name: "events_lea_index", using: :btree
  add_index "court_calendar_events", ["sheriff_number"], name: "index_court_calendar_events_on_sheriff_number", using: :btree

  create_table "court_calendar_page_headers", force: :cascade do |t|
    t.integer  "court_calendar_page_id", null: false
    t.string   "jurisdiction"
    t.string   "judge"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "court_calendar_page_headers", ["court_calendar_page_id"], name: "headers_page_fk", using: :btree

  create_table "court_calendar_pages", force: :cascade do |t|
    t.integer  "court_calendar_id", null: false
    t.integer  "number",            null: false
    t.boolean  "parsable"
    t.text     "parsing_errors"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "court_calendar_pages", ["court_calendar_id", "number"], name: "pages_composite_key", unique: true, using: :btree
  add_index "court_calendar_pages", ["court_calendar_id"], name: "index_court_calendar_pages_on_court_calendar_id", using: :btree

  create_table "court_calendars", force: :cascade do |t|
    t.integer  "court_id",     null: false
    t.text     "url",          null: false
    t.datetime "created_at"
    t.datetime "modified_at",  null: false
    t.datetime "requested_at"
    t.integer  "page_count"
  end

  add_index "court_calendars", ["court_id", "url", "modified_at"], name: "calendars_composite_key", unique: true, using: :btree
  add_index "court_calendars", ["court_id"], name: "index_court_calendars_on_court_id", using: :btree

  create_table "courts", force: :cascade do |t|
    t.string   "type",         null: false
    t.string   "name",         null: false
    t.text     "calendar_url"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "courts", ["name"], name: "index_courts_on_name", using: :btree
  add_index "courts", ["type", "name"], name: "index_courts_on_type_and_name", unique: true, using: :btree
  add_index "courts", ["type"], name: "index_courts_on_type", using: :btree

  create_table "developer_accounts", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "developer_accounts", ["email"], name: "index_developer_accounts_on_email", unique: true, using: :btree
  add_index "developer_accounts", ["reset_password_token"], name: "index_developer_accounts_on_reset_password_token", unique: true, using: :btree

end
