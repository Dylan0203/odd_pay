module OddPay
  class PaymentGatewayService
    AVAILABLE_GATEWAYS = %i(NewebPay).freeze
    PAYMENT_METHOD_MAP = {
      NewebPay: %i(subscription)
    }.freeze
  end
end
