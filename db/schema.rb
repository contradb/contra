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

ActiveRecord::Schema.define(version: 20171216025445) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer  "index",      null: false
    t.integer  "program_id", null: false
    t.integer  "dance_id"
    t.text     "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dance_id"], name: "index_activities_on_dance_id", using: :btree
    t.index ["program_id"], name: "index_activities_on_program_id", using: :btree
  end

  create_table "choreographers", force: :cascade do |t|
    t.string   "name",       default: "", null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "publish"
    t.string   "website"
    t.index ["name"], name: "index_choreographers_on_name", unique: true, using: :btree
  end

  create_table "dances", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title",            default: "",   null: false
    t.integer  "choreographer_id"
    t.string   "start_type",       default: "",   null: false
    t.text     "notes",            default: "",   null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.text     "figures_json",     default: "[]", null: false
    t.boolean  "publish",          default: true, null: false
    t.text     "preamble",         default: ""
    t.text     "hook",             default: ""
  end

  create_table "programs", force: :cascade do |t|
    t.string   "title",      limit: 100, null: false
    t.integer  "user_id",                null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["user_id"], name: "index_programs_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                              default: "",    null: false
    t.string   "encrypted_password",                 default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "name",                   limit: 128
    t.boolean  "admin",                              default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "activities", "dances"
  add_foreign_key "activities", "programs"
  add_foreign_key "programs", "users"
end
