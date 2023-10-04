# == Schema Information
#
# Table name: odd_pay_payments
#
#  id              :bigint           not null, primary key
#  payment_info_id :bigint
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("USD"), not null
#  paid_at         :datetime
#  expired_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
module OddPay
  class Payment < ApplicationRecord
    belongs_to :payment_info, touch: true
    has_one :invoice, through: :payment_info
    has_one :uniform_invoice

    validates :paid_at, uniqueness: { scope: :payment_info_id }

    monetize :amount_cents
  end
end
