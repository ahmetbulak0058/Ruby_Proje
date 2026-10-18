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

ActiveRecord::Schema[8.1].define(version: 2026_10_18_163644) do
  create_table "comments", force: :cascade do |t|
    t.integer "ticket_id", null: false
    t.string "author_name", null: false
    t.string "author_role", default: "customer", null: false
    t.text "body", null: false
    t.boolean "internal_note", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id"], name: "index_comments_on_ticket_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "reference_code", null: false
    t.string "customer_name", null: false
    t.string "customer_email", null: false
    t.string "subject", null: false
    t.text "description"
    t.string "status", default: "new", null: false
    t.string "priority", default: "normal", null: false
    t.string "assigned_agent"
    t.datetime "sla_due_at"
    t.datetime "first_responded_at"
    t.datetime "resolved_at"
    t.boolean "reopen_prevented", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority"], name: "index_tickets_on_priority"
    t.index ["reference_code"], name: "index_tickets_on_reference_code", unique: true
    t.index ["sla_due_at"], name: "index_tickets_on_sla_due_at"
    t.index ["status"], name: "index_tickets_on_status"
  end

  add_foreign_key "comments", "tickets"
end
