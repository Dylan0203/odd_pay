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

ActiveRecord::Schema.define(version: 2022_10_28_100020) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "odd_pay_invoices", force: :cascade do |t|
    t.string "buyer_type"
    t.bigint "buyer_id"
    t.string "payable_type"
    t.bigint "payable_id"
    t.string "billing_email"
    t.string "billing_phone"
    t.string "billing_address"
    t.string "title"
    t.text "description"
    t.text "note"
    t.integer "invoice_type", default: 0
    t.jsonb "subscription_info", default: {}
    t.string "aasm_state"
    t.jsonb "item_list", default: []
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["buyer_type", "buyer_id"], name: "index_odd_pay_invoices_on_buyer"
    t.index ["payable_type", "payable_id"], name: "index_odd_pay_invoices_on_payable"
  end

end
