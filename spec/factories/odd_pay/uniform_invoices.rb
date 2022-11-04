# == Schema Information
#
# Table name: odd_pay_uniform_invoices
#
#  id                         :bigint           not null, primary key
#  payment_id                 :bigint
#  uniform_invoice_gateway_id :bigint
#  invoice_trans_no           :string
#  total_amount_cents         :integer          default(0), not null
#  total_amount_currency      :string           default("USD"), not null
#  invoice_number             :string
#  random_number              :string
#  bar_code                   :string
#  qr_code_l                  :string
#  qr_code_r                  :string
#  create_time                :datetime
#  status_message             :string
#  aasm_state                 :string
#  comment                    :text
#  raw_data                   :jsonb
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
FactoryBot.define do
  factory :uniform_invoice, class: 'OddPay::UniformInvoice' do

  end
end
