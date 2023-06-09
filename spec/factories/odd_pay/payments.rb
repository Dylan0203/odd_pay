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
FactoryBot.define do
  factory :payment, class: 'OddPay::Payment' do
    payment_info
  end
end
