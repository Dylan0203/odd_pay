module OddPay
  module NewebPay
    class NotificationUpdater
      include OddPay::Composables::ApiClient
      include OddPay::Composables::InformationComposer

      attr_reader :notification, :raw_data

      def initialize(notification)
        @gateway_source = notification
        @notification = notification
        @raw_data = notification.raw_data
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
        @decode_data ||= api_client.decode_period_params(
          raw_data['TradeInfo'] ||
            raw_data['Period'] ||
            raw_data['period']
        )
      end

      def api_succeed
        decode_data["Status"] == "SUCCESS"
      end

      def response_type
        case notification.reference.to_sym
        when :payment_notify
          return api_succeed ? :paid : :failed
        when :async_payment_notify
          return :async_payment_info if api_succeed
        when :cancel_notify
          return :canceled if api_succeed
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
        Time.zone.parse(
          decode_data["Result[AuthTime]"] ||
            decode_data["Result[AuthDate]"] ||
            decode_data['PayTime'] ||
            ''
        )
      end

      def card_no
        decode_data["Result[CardNo]"] ||
          [
            decode_data['Card6No'],
            decode_data['Card4No']
          ].
            compact.
            join('******')
      end

      def auth_code
        decode_data["Result[AuthCode]"] || decode_data['Auth']
      end

      def amount
        decode_data["Result[PeriodAmt]"] ||
          decode_data["Result[AuthAmt]"] ||
          decode_data['Amt']
      end

      def original_info
        decode_data
      end
    end
  end
end
