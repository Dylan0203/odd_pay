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
module OddPay
  class PaymentGateway < ApplicationRecord
    has_many :payment_methods

    validate { OddPay::PaymentGateway::DataValidator.new(self).validate }

    def available_payment_types
      OddPay::PaymentGatewayService::PAYMENT_TYPES &
        "OddPay::#{gateway_provider}::AVAILABLE_PAYMENT_TYPES".constantize
    end
  end
end
