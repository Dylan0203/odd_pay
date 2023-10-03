module OddPay
  module Offline
    class PaymentInfoCanceler
      include OddPay::Composables::PaymentGatewayApiClient

      attr_reader :payment_info, :invoice, :amount

      def initialize(payment_info, amount)
        @payment_info = payment.payment_info
        @invoice = payment_info.invoice
        @amount = amount || payment_info.amount.to_i
      end

      def self.call(payment_info, amount: nil)
        new(payment_info, amount).call
      end

      def call
        notification = payment_info.notifications.create!(
          raw_data: {
            Message: 'Payment Canceled',
            Amount: amount
          },
          reference: :cancel_notify
        )

        notification.update_info
        payment_info.update_info
      end
    end
  end
end
