module OddPay
  module Offline
    class NotificationUpdater
      include OddPay::Composables::InformationComposer

      attr_reader :notification, :raw_data, :reference

      def initialize(notification)
        @notification = notification
        @raw_data = notification.raw_data
        @reference = notification.reference.to_sym
      end

      def self.update(notification)
        new(notification).update
      end

      def update
        notification.update!(
          notify_type: build_information[:response_type],
          information: build_information
        )
      end

      def self.parse_notification(notification)
        new(notification).build_information
      end

      def decode_data
        raw_data
      end

      def api_succeed
        true
      end

      def response_type
        case reference
        when :payment_notify
          return :paid
        when :cancel_notify
          return :canceled
        when :refund_notify
          return :refunded
        end

        :init
      end

      def message
        decode_data['Message']
      end

      def is_valid
        true
      end

      def paid_at
        decode_data['paid_at']
      end

      def card_no
        decode_data['card_no']
      end

      def auth_code
        decode_data['auth_code']
      end

      def amount
        decode_data["amount"]
      end

      def original_info
        decode_data
      end

      def code_no
        decode_data['code_no']
      end

      def bank_code
        decode_data['bank_code']
      end

      def expired_at
        decode_data['expired_at']
      end
    end
  end
end
