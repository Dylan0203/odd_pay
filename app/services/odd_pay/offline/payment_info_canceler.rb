module OddPay
  module Offline
    class PaymentInfoCanceler
      include OddPay::Composables::PaymentGatewayApiClient

      attr_reader :payment_info, :payment_type, :invoice, :amount

      def initialize(payment_info, amount: nil)
        @payment_info = payment_info
        @invoice = payment_info.invoice
        @amount = amount || payment_info.amount.to_i
      end

      def self.call(payment_info)
        new(payment_info).call
      end

      def call
        payment_info.notifications.create!(
          raw_data: {
            Message: 'Payment Canceled',
            Amount: amount
          },
          reference: :cancel_notify
        )

        OddPay::PaymentGatewayService.update_notification(notifications.last)
        OddPay::PaymentGatewayService.update_payment_info(payment_info)
        OddPay::PaymentGatewayService.update_invoice(invoice)
      end
    end
  end
end
