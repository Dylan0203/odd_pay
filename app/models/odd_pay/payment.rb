# == Schema Information
#
# Table name: odd_pay_payments
#
#  id              :bigint           not null, primary key
#  payment_info_id :bigint
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("USD"), not null
#  started_at      :datetime
#  ended_at        :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
module OddPay
  class Payment < ApplicationRecord
    belongs_to :payment_info, touch: true
    has_one :uniform_invoice

    monetize :amount_cents
  end
end
