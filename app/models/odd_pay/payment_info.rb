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
    include AASM

    belongs_to :invoice, touch: true
    belongs_to :payment_method
    has_many :notifications
    has_many :payments

    aasm do
      state :checkout, initial: true
      state :processing
      state :paid
      state :overdue
      state :failed
      state :canceled
      state :void

      event :process do
        transitions from: %i(checkout), to: :processing
      end

      event :pay do
        transitions from: %i(processing paid overdue), to: :paid
      end

      event :expire do
        transitions from: %i(paid), to: :overdue
      end

      event :fail do
        transitions from: %i(processing), to: :failed
      end

      event :cancel do
        transitions from: %i(checkout processing paid), to: :canceled
      end

      event :ignore do
        transitions from: %i(processing), to: :void
      end
    end
    end
  end
end
