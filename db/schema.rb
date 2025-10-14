# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_13_201829) do
  create_table "signatures", force: :cascade do |t|
    t.string "name"
    t.string "email", null: false
    t.string "title"
    t.string "organization"
    t.string "profile_url"
    t.integer "signature_type"
    t.string "confirmation_token", null: false
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmation_code_sent_at"
    t.datetime "signed_at"
    t.index ["confirmation_token"], name: "index_signatures_on_confirmation_token", unique: true
    t.index ["email"], name: "index_signatures_on_email", unique: true
    t.index ["signed_at", "created_at"], name: "index_signatures_on_signed_at_and_created_at"
    t.index ["signed_at"], name: "index_signatures_on_signed_at"
  end
end
