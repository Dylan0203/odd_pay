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
        decode_data['PaidAt']
      end

      def card_no
        decode_data['CardNo']
      end

      def auth_code
        decode_data['AuthCode']
      end

      def amount
        decode_data["Amount"]
      end

      def original_info
        decode_data
      end

      def code_no
        decode_data['CodeNo']
      end

      def bank_code
        decode_data['BankCode']
      end

      def expired_at
        decode_data['ExpiredAt']
      end
    end
  end
end
