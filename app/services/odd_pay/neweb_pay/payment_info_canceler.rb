module OddPay
  module NewebPay
    class PaymentInfoCanceler
      include OddPay::Composables::PaymentGatewayApiClient

      attr_reader :payment_info, :notifications, :payment_type, :merchant_order_number, :amount

      def initialize(payment_info, amount: nil)
        @gateway_source = payment_info
        @payment_info = payment_info
        @notifications = payment_info.notifications
        @payment_type = payment_info.payment_type
        @merchant_order_number = payment_info.merchant_order_number
        @amount = amount || payment_info.amount.to_i
      end

      def self.call(payment_info, amount: nil)
        new(payment_info, amount: amount).call
      end

      def call
        case payment_type
        when :subscription
          OddPay::NewebPay::SubscriptionCanceler.call(payment_info)
        else
          if is_credit_card_full_refund?
            try_deauthorize
          else
            try_refund
          end
        end

        payment_info.update_info
      end

      private

      def try_deauthorize
        return if deauthorize == true

        try_refund
      end

      def try_refund
        return if refund == true

        collect
        refund
      end

      def deauthorize
        OddPay::NewebPay::Deauthorizer.call(payment_info)
      end

      def collect
        OddPay::NewebPay::Collector.call(payment_info)
      end

      def refund
        OddPay::NewebPay::RefundApplier.call(payment_info, amount: amount)
      end

      def is_credit_card_full_refund?
        amount == payment_info.amount.to_i &&
          payment_type.to_s.include?('credit_card')
      end
    end
  end
end
