# == Schema Information
#
# Table name: odd_pay_payment_gateways
#
#  id                      :bigint           not null, primary key
#  name                    :string
#  gateway_provider        :string
#  gateway_info            :jsonb
#  historical_gateway_info :jsonb
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
FactoryBot.define do
  factory :payment_gateway, class: 'OddPay::PaymentGateway' do
    gateway_provider { :NewebPay }
    gateway_info do
      {
        hash_iv: 'hash_iv',
        hash_key: 'hash_key',
        merchant_id: 'merchant_id'
      }
    end
  end
end
