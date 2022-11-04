# == Schema Information
#
# Table name: odd_pay_payment_methods
#
#  id                 :bigint           not null, primary key
#  payment_gateway_id :bigint
#  name               :string
#  description        :text
#  payment_type       :string
#  enabled            :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
FactoryBot.define do
  factory :payment_method, class: 'OddPay::PaymentMethod' do
    payment_gateway
  end
end
