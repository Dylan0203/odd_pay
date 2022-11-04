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
require 'rails_helper'

module OddPay
  RSpec.describe PaymentInfo, type: :model do
    # associations
    it { should belong_to(:invoice) }
    it { should belong_to(:payment_method) }
    it { should have_many(:notifications) }
    it { should have_many(:payments) }
  end
end
