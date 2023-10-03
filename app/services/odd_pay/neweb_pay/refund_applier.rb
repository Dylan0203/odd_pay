module OddPay
  module NewebPay
    class RefundApplier
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
        when *OddPay::NewebPay::EWALLET_PAYMENT_TYPES
          ewallet_refund
        else
          normal_refund
        end
      end

      private

      def normal_refund
        params = {
          MerchantOrderNo: merchant_order_number,
          Amt: amount
        }

        notification = notifications.create!(
          raw_data: api_client.credit_card_refund_by_merchant_order_no(params),
          reference: :refund_notify
        )

        notification.update_info
        notification.refunded?
      end

      def ewallet_refund
        params = {
          MerchantOrderNo: merchant_order_number,
          Amount: amount,
          PaymentType: OddPay::NewebPay::PostInfoGenerator::PAYMENT_METHOD_PARAMS[payment_type].keys[0]
        }

        notification = notifications.create!(
          raw_data: api_client.ewallet_refund_by_merchant_order_no(params),
          reference: :refund_notify
        )

        notification.update_info
        notification.refunded?
      end
    end
  end
end
