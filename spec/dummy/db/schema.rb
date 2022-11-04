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

ActiveRecord::Schema.define(version: 2022_11_04_055920) do

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

  create_table "odd_pay_notifications", force: :cascade do |t|
    t.bigint "payment_info_id"
    t.jsonb "raw_data"
    t.integer "notify_type", default: 0
    t.jsonb "information"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_info_id"], name: "index_odd_pay_notifications_on_payment_info_id"
  end

  create_table "odd_pay_payment_gateways", force: :cascade do |t|
    t.string "name"
    t.string "gateway_provider"
    t.jsonb "gateway_info", default: {}
    t.jsonb "historical_gateway_info", default: []
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "odd_pay_payment_infos", force: :cascade do |t|
    t.bigint "invoice_id"
    t.bigint "payment_method_id"
    t.string "merchant_order_number"
    t.string "aasm_state"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.jsonb "gateway_info", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["invoice_id"], name: "index_odd_pay_payment_infos_on_invoice_id"
    t.index ["payment_method_id"], name: "index_odd_pay_payment_infos_on_payment_method_id"
  end

  create_table "odd_pay_payment_methods", force: :cascade do |t|
    t.bigint "payment_gateway_id"
    t.string "name"
    t.text "description"
    t.string "payment_type"
    t.boolean "enabled", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_gateway_id"], name: "index_odd_pay_payment_methods_on_payment_gateway_id"
  end

  create_table "odd_pay_payments", force: :cascade do |t|
    t.bigint "payment_info_id"
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_info_id"], name: "index_odd_pay_payments_on_payment_info_id"
  end

  create_table "odd_pay_uniform_invoice_gateways", force: :cascade do |t|
    t.string "name"
    t.string "gateway_provider"
    t.boolean "is_default", default: false
    t.boolean "is_enabled", default: false
    t.jsonb "gateway_info", default: {}
    t.jsonb "historical_gateway_info", default: []
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "odd_pay_uniform_invoices", force: :cascade do |t|
    t.bigint "payment_id"
    t.bigint "uniform_invoice_gateway_id"
    t.string "invoice_trans_no"
    t.integer "total_amount_cents", default: 0, null: false
    t.string "total_amount_currency", default: "USD", null: false
    t.string "invoice_number"
    t.string "random_number"
    t.string "bar_code"
    t.string "qr_code_l"
    t.string "qr_code_r"
    t.datetime "create_time"
    t.string "status_message"
    t.string "aasm_state"
    t.text "comment"
    t.jsonb "raw_data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["payment_id"], name: "index_odd_pay_uniform_invoices_on_payment_id"
    t.index ["uniform_invoice_gateway_id"], name: "index_odd_pay_uniform_invoices_on_uniform_invoice_gateway_id"
  end

  add_foreign_key "odd_pay_notifications", "odd_pay_payment_infos", column: "payment_info_id"
  add_foreign_key "odd_pay_payment_infos", "odd_pay_invoices", column: "invoice_id"
  add_foreign_key "odd_pay_payment_infos", "odd_pay_payment_methods", column: "payment_method_id"
  add_foreign_key "odd_pay_payment_methods", "odd_pay_payment_gateways", column: "payment_gateway_id"
  add_foreign_key "odd_pay_payments", "odd_pay_payment_infos", column: "payment_info_id"
  add_foreign_key "odd_pay_uniform_invoices", "odd_pay_payments", column: "payment_id"
  add_foreign_key "odd_pay_uniform_invoices", "odd_pay_uniform_invoice_gateways", column: "uniform_invoice_gateway_id"
end
