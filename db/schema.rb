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

ActiveRecord::Schema.define(version: 20170320090805) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "registrations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "event_ids"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "accepted_at"
    t.string   "deleted_at"
    t.string   "competition_id"
    t.string   "comments"
    t.datetime "confirmed_at"
    t.integer  "confirmed_by"
    t.index ["user_id"], name: "index_registrations_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "wca_id"
    t.string   "country_iso2"
    t.string   "email"
    t.string   "avatar_url"
    t.string   "avatar_thumb_url"
  end

end
