module OddPay
  module NewebPay
    class Deauthorizer
      include OddPay::Composables::PaymentGatewayApiClient

      attr_reader :payment_info, :notifications, :merchant_order_number, :amount

      def initialize(payment_info)
        @gateway_source = payment_info
        @payment_info = payment_info
        @notifications = payment_info.notifications
        @merchant_order_number = payment_info.merchant_order_number
      end

      def self.call(payment)
        new(payment).call
      end

      def call
        params = {
          MerchantOrderNo: merchant_order_number,
          Amt: payment_info.amount.to_i
        }

        notification = notifications.create!(
          raw_data: api_client.credit_card_deauthorize_by_merchant_order_no(params),
          reference: :deauthorize_notify
        )

        notification.update_info
        notification.deauthorized?
      end
    end
  end
end
