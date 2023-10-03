module OddPay
  module NewebPay
    class SubscriptionCanceler
      include OddPay::Composables::PaymentGatewayApiClient

      attr_reader :payment_info, :notifications, :merchant_order_number, :amount

      def initialize(payment_info)
        @gateway_source = payment_info
        @payment_info = payment_info
        @notifications = payment_info.notifications
        @merchant_order_number = payment_info.merchant_order_number
      end

      def self.call(payment_info)
        new(payment_info).call
      end

      def call
        params = {
          MerOrderNo: merchant_order_number,
          PeriodNo: notifications.paid.last.information.dig('original_info', 'Result', 'PeriodNo'),
          AlterType: 'terminate'
        }

        notification = notifications.create!(
          raw_data: api_client.change_subscription_status(params),
          reference: :cancel_notify
        )

        notification.update_info
        notification.canceled?
      end
    end
  end
end
