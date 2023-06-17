module OddPay
  module Composables
    module InformationComposer
      NotImplementedError = Class.new(StandardError)
      InvalidNotificationError = Class.new(StandardError)
      FETCH_DATA_METHODS = %i(
        response_type
        message
        is_valid
        paid_at
        card_no
        auth_code
        amount
        original_info
        decode_data
      ).freeze

      def build_information
        raise InvalidNotificationError unless is_valid

        @build_information ||= {
          response_type: response_type,
          message: message,
          is_valid: is_valid,
          paid_at: paid_at,
          card_no: card_no,
          auth_code: auth_code,
          amount: amount,
          original_info: original_info,
          bank_code: bank_code,
          code_no: code_no,
          expired_at: expired_at
        }.compact
      end

      private

      FETCH_DATA_METHODS.each do |method_name|
        define_method(method_name) do
          raise NotImplementedError, %(Please implement `#{self.class.name}##{method_name}`)
        end
      end
    end
  end
end
