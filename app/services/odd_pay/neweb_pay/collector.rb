module OddPay
  module NewebPay
    class Collector
      include OddPay::Composables::PaymentGatewayApiClient

      InvalidPaymentType = Class.new(StandardError)

      attr_reader :payment_info, :notifications, :payment_type, :merchant_order_number, :amount

      def initialize(payment_info)
        @gateway_source = payment_info
        @payment_info = payment_info
        @notifications = payment_info.notifications
        @payment_type = payment_info.payment_type
        @merchant_order_number = payment_info.merchant_order_number
      end

      def self.call(payment_info)
        new(payment_info).call
      end

      def call
        params = {
          MerchantOrderNo: merchant_order_number,
          Amt: payment_info.amount.to_i
        }

        notification = notifications.create!(
          raw_data: api_client.credit_card_collect_by_merchant_order_no(params),
          reference: :collect_notify
        )

        notification.update_info
        notification.collected?
      end
    end
  end
end
