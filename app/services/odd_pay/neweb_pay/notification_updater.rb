module OddPay
  module NewebPay
    class NotificationUpdater
      include OddPay::Composables::PaymentGatewayApiClient
      include OddPay::Composables::InformationComposer

      attr_reader :notification, :raw_data, :payment_type, :reference

      def initialize(notification)
        @gateway_source = notification
        @notification = notification
        @raw_data = notification.raw_data
        @payment_type = notification.payment_info.payment_type.to_s
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
        @decode_data ||= begin
          case reference
          when :deauthorize_notify, :payment_info_notify
            data = raw_data['Result']
            data.class == Hash ? data : {} # there might be an array
          else
            data = raw_data['TradeInfo'] ||
              raw_data['Period'] ||
              raw_data['period'] ||
              raw_data['EncryptData']

            data.present? ? api_client.decode_json_data(data) : raw_data
          end.with_indifferent_access
        end
      end

      def api_succeed
        case reference
        when :deauthorize_notify, :payment_info_notify
          raw_data['Status'] == "SUCCESS"
        when :refund_notify
          decode_data[:Status] == "SUCCESS" ||
            raw_data['Status'] == '1000'
        else
          decode_data[:Status] == "SUCCESS"
        end
      end

      def is_valid
        case reference
        when :deauthorize_notify, :payment_info_notify
          return true unless api_succeed # no check code if not success

          api_client.verify_check_code(raw_data['Result'])
        else
          true
        end
      end

      def response_type
        if api_succeed
          case reference
          when :payment_notify
            :paid
          when :async_payment_notify
            :async_payment_info
          when :cancel_notify
            :canceled
          when :collect_notify
            :collected
          when :deauthorize_notify
            :deauthorized
          when :refund_notify
            :refunded
          when :payment_info_notify
            :current_payment_info
          end
        else
          reference == :payment_notify ? :failed : :init
        end
      end

      def message
        decode_data.dig(:Message) ||
          raw_data['Message']
      end

      def paid_at
        Time.zone.parse(
          decode_data.dig(:Result, :AuthTime) ||
            decode_data.dig(:Result, :AuthDate) ||
            decode_data.dig(:Result, :PayTime) ||
            ''
        )
      end

      def card_no
        result = decode_data.dig(:Result, :CardNo) ||
                   [
                     decode_data.dig(:Result, :Card6No),
                     decode_data.dig(:Result, :Card4No)
                   ].
                     compact.
                     join('******')
        result.present? ? result : nil
      end

      def auth_code
        decode_data.dig(:Result, :AuthCode) ||
          decode_data.dig(:Result, :Auth)
      end

      def amount
        decode_data.dig(:Result, :PeriodAmt) ||
          decode_data.dig(:Result, :AuthAmt) ||
          decode_data.dig(:Result, :Amt) ||
          decode_data.dig(:Amt) ||
          decode_data.dig(:Result, :RefundAmount)
      end

      def original_info
        decode_data
      end

      def code_no
        decode_data.dig(:Result, :CodeNo)
      end

      def bank_code
        decode_data.dig(:Result, :BankCode)
      end

      def expired_at
        [
          decode_data.dig(:Result, :ExpireDate),
          decode_data.dig(:Result, :ExpireTime)
        ].
          compact.
          join(' ').
          in_time_zone
      end
    end
  end
end
