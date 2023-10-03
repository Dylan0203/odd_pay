# == Schema Information
#
# Table name: odd_pay_refunds
#
#  id              :bigint           not null, primary key
#  payment_info_id :bigint
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("USD"), not null
#  aasm_state      :string
#  refunded_at     :datetime
#  bank_code       :string
#  account         :string
#  recipient       :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
module OddPay
  class Refund < ApplicationRecord
    include AASM

    belongs_to :payment_info, touch: true

    monetize :amount_cents

    aasm do
      state :pending, initial: true
      state :processing
      state :done

      event :process do
        transitions from: %i(pending), to: :processing
      end

      event :complete do
        transitions from: %i(pending processing), to: :done
      end
    end
  end
end
