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
#
module OddPay
  class PaymentInfo < ApplicationRecord
    belongs_to :invoice, touch: true
    belongs_to :payment_method
    has_many :notifications
    has_many :payments
  end
end
