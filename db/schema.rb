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

ActiveRecord::Schema.define(version: 20180815033956) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", id: :serial, force: :cascade do |t|
    t.integer "index", null: false
    t.integer "program_id", null: false
    t.integer "dance_id"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dance_id"], name: "index_activities_on_dance_id"
    t.index ["program_id"], name: "index_activities_on_program_id"
  end

  create_table "choreographers", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "publish"
    t.string "website"
    t.index ["name"], name: "index_choreographers_on_name", unique: true
  end

  create_table "dances", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "title", default: "", null: false
    t.integer "choreographer_id"
    t.string "start_type", default: "", null: false
    t.text "notes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "figures_json", default: "[]", null: false
    t.boolean "publish", default: true, null: false
    t.text "preamble", default: "", null: false
    t.text "hook", default: "", null: false
  end

  create_table "idioms", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.string "term", null: false
    t.string "substitution", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_idioms_on_user_id"
  end

  create_table "programs", id: :serial, force: :cascade do |t|
    t.string "title", limit: 100, null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_programs_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", limit: 128
    t.boolean "admin", default: false, null: false
    t.boolean "news_email", default: true, null: false
    t.integer "moderation", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "activities", "dances"
  add_foreign_key "activities", "programs"
  add_foreign_key "idioms", "users"
  add_foreign_key "programs", "users"
end
