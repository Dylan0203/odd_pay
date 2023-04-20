module OddPay
  module NewebPay
    class PaymentInfoCanceler
      include OddPay::Composables::ApiClient

      attr_reader :payment_info, :payment_type, :invoice, :merchant_order_number, :amount

      def initialize(payment_info, amount: nil)
        @payment_info = payment_info
        @gateway_source = payment_info
        @payment_type = payment_info.payment_type
        @invoice = payment_info.invoice
        @merchant_order_number = payment_info.merchant_order_number
        @amount = amount || payment_info.amount.to_i
      end

      def self.call(payment_info)
        new(payment_info).call
      end

      def call
        case payment_type
        when :subscription
          cancel_subscription_and_save_notification
        else
          cancel_normal_payment_and_save_notification
        end

        OddPay::PaymentGatewayService.update_notification(notifications.last)
        OddPay::PaymentGatewayService.update_payment_info(payment_info)
        OddPay::PaymentGatewayService.update_invoice(payment_info.invoice)
      end

      private

      def notifications
        payment_info.notifications
      end

      def cancel_subscription_and_save_notification
        params = {
          MerOrderNo: merchant_order_number,
          PeriodNo: notifications.paid.last.information['original_info']['Result[PeriodNo]'],
          AlterType: 'terminate'
        }

        notifications.create!(
          raw_data: api_client.change_subscription_status(params, decode: false),
          reference: :cancel_notify
        )
      end

      def cancel_normal_payment_and_save_notification
        if payment_type.include?(:credit_card)
          raw_data = api_client.credit_detail_do_action(
            merchant_order_number,
            notifications.paid.last.information['original_info']['TradeNo'],
            :N,
            amount
          )

          notifications.create!(
            raw_data: raw_data,
            reference: :cancel_notify
          )

        else
          notification = create_cc_deauthorize_notification

          OddPay::PaymentGatewayService.update_notification(notification) if notification
          unless notification.try(:canceled?)

          end
        end
      end

      def create_cc_deauthorize_notification
        raw_data = api_cient.credit_card_deauthorize_by_merchant_order_no(
          MerchantOrderNo: merchant_order_number,
          Amt: amount
        )

        notification = notifications.create!(
          raw_data: raw_data,
          reference: :cancel_notify
        )
      end
    end
  end
end
