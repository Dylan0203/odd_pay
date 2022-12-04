module OddPay
  class PaymentInfo::DataValidator
    attr_reader :payment_info, :errors

    def initialize(payment_info)
      @payment_info = payment_info
      @errors = payment_info.errors
    end

    def validate
      if payment_info.checkout?
        assign_gateway_info
        assign_amount
      end
    end

    def assign_gateway_info
      payment_method = payment_info.payment_method
      return unless payment_method

      payment_info.gateway_info = {
        gateway_id: payment_method.payment_gateway.id,
        payment_type: payment_method.payment_type
      }
    end

    def assign_amount
      payment_info.assign_attributes amount: payment_info.invoice.amount
    end
  end
end
