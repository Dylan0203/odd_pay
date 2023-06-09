module OddPay
  module NewebPay
    class MerchantOrderNumberGenerator
      attr_reader :payment_info, :invoice

      def initialize(payment_info)
        @payment_info = payment_info
        @invoice = payment_info.invoice
      end

      def self.call(payment_info)
        new(payment_info).call
      end

      def call
        invoice_id = invoice.id.to_s(36).upcase
        payment_info_id = payment_info.id.to_s(36).upcase
        timestamp = Time.current.to_i.to_s(36).upcase

        %(#{invoice_id}_#{payment_info_id}_#{timestamp})
      end
    end
  end
end
