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

ActiveRecord::Schema.define(version: 20180216145606) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "competitions", id: :string, force: :cascade do |t|
    t.string   "name"
    t.string   "admin_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "round_id"
    t.string   "color"
    t.index ["round_id"], name: "index_groups_on_round_id", using: :btree
  end

  create_table "guests", force: :cascade do |t|
    t.integer  "registration_id", null: false
    t.string   "name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["registration_id"], name: "index_guests_on_registration_id", using: :btree
  end

  create_table "person_round_colors", force: :cascade do |t|
    t.string  "wca_id"
    t.string  "event_id"
    t.integer "color"
  end

  create_table "personal_bests", force: :cascade do |t|
    t.integer "user_id",                         null: false
    t.string  "result_type",                     null: false
    t.string  "event_id",                        null: false
    t.integer "best",                default: 0, null: false
    t.integer "world_ranking",       default: 0, null: false
    t.integer "continental_ranking", default: 0, null: false
    t.integer "national_ranking",    default: 0, null: false
    t.index ["event_id"], name: "index_personal_bests_on_event_id", using: :btree
    t.index ["user_id"], name: "index_personal_bests_on_user_id", using: :btree
  end

  create_table "public_guests", force: :cascade do |t|
    t.string   "fullname"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "registration_details", force: :cascade do |t|
    t.integer  "registration_id",                   null: false
    t.string   "tshirt"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.datetime "confirmed_at"
    t.boolean  "staff",             default: false
    t.datetime "cancelled_at"
    t.boolean  "runner_only",       default: false
    t.integer  "mbf1",              default: 0
    t.integer  "mbf2",              default: 0
    t.integer  "mbf3",              default: 0
    t.boolean  "mbf_judge",         default: false
    t.integer  "restaurant_guests", default: 0
    t.index ["registration_id"], name: "index_registration_details_on_registration_id", using: :btree
  end

  create_table "registration_groups", force: :cascade do |t|
    t.integer "registration_id", null: false
    t.integer "group_id"
    t.index ["group_id"], name: "index_registration_groups_on_group_id", using: :btree
    t.index ["registration_id"], name: "index_registration_groups_on_registration_id", using: :btree
  end

  create_table "registrations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "event_ids"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "competition_id"
    t.string   "comments"
    t.string   "status"
    t.index ["user_id"], name: "index_registrations_on_user_id", using: :btree
  end

  create_table "rounds", force: :cascade do |t|
    t.integer  "r_id"
    t.string   "event_id"
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_rounds_on_event_id", using: :btree
  end

  create_table "schedule_events", force: :cascade do |t|
    t.string   "name"
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scramble_events", force: :cascade do |t|
    t.integer  "registration_id"
    t.string   "event_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["registration_id"], name: "index_scramble_events_on_registration_id", using: :btree
  end

  create_table "staff_registrations_groups", force: :cascade do |t|
    t.integer "registration_id", null: false
    t.integer "group_id",        null: false
    t.string  "role"
    t.index ["group_id"], name: "index_staff_registrations_groups_on_group_id", using: :btree
    t.index ["registration_id"], name: "index_staff_registrations_groups_on_registration_id", using: :btree
  end

  create_table "staff_team_members", force: :cascade do |t|
    t.integer  "staff_team_id",                   null: false
    t.integer  "registration_id",                 null: false
    t.boolean  "team_leader",     default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["registration_id"], name: "index_staff_team_members_on_registration_id", using: :btree
    t.index ["staff_team_id"], name: "index_staff_team_members_on_staff_team_id", using: :btree
  end

  create_table "staff_teams", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "comments"
  end

  create_table "staff_teams_groups", force: :cascade do |t|
    t.integer "staff_team_id", null: false
    t.integer "group_id",      null: false
    t.index ["group_id"], name: "index_staff_teams_groups_on_group_id", using: :btree
    t.index ["staff_team_id"], name: "index_staff_teams_groups_on_staff_team_id", using: :btree
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
    t.string   "gender"
    t.date     "birthdate"
  end

end
