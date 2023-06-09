# == Schema Information
#
# Table name: odd_pay_uniform_invoice_credit_notes
#
#  id                     :bigint           not null, primary key
#  uniform_invoice_id     :bigint
#  number                 :string
#  invoice_number         :string
#  create_time            :datetime
#  remain_amount_cents    :integer          default(0), not null
#  remain_amount_currency :string           default("USD"), not null
#  raw_data               :jsonb
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
FactoryBot.define do
  factory :uniform_invoice_credit_note, class: 'OddPay::UniformInvoiceCreditNote' do
    uniform_invoice
  end
end
