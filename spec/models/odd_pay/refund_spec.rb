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
require 'rails_helper'

module OddPay
  RSpec.describe Refund, type: :model do
    # associations
    it { should belong_to(:payment_info) }
  end
end
