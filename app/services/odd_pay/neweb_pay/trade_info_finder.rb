module OddPay
  module NewebPay
    class TradeInfoFinder
      include OddPay::Composables::PaymentGatewayApiClient

      InvalidPaymentType = Class.new(StandardError)

      attr_reader :payment_info, :merchant_order_number

      def initialize(payment_info)
        @gateway_source = payment_info
        @payment_info = payment_info
        @merchant_order_number = payment_info.merchant_order_number
      end

      def self.call(payment_info)
        new(payment_info).call
      end

      def call
        raise InvalidPaymentType, 'payment type `subscription` is NOT supported.' if payment_info.payment_type == :subscription

        params = {
          MerchantOrderNo: merchant_order_number,
          Amt: payment_info.amount.to_i
        }

        notification = payment_info.notifications.create!(
          raw_data: api_client.query_trade_info(params),
          reference: :payment_info_notify
        )

        notification.update_info
        notification.current_payment_info?
      end
    end
  end
end
