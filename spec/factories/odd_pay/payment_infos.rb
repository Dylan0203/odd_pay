# == Schema Information
#
# Table name: odd_pay_payment_infos
#
#  id                    :bigint           not null, primary key
#  invoice_id            :bigint
#  payment_method_id     :bigint
#  merchant_order_number :string
#  aasm_state            :string
#  amount_cents          :integer          default(0), not null
#  amount_currency       :string           default("USD"), not null
#  gateway_info          :jsonb
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  refund_state          :string
#
FactoryBot.define do
  factory :payment_info, class: 'OddPay::PaymentInfo' do
    invoice
    payment_method
  end
end
