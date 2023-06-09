module OddPay
  class PaymentInfo::DataValidator
    attr_reader :payment_info, :invoice, :payment_method, :errors

    def initialize(payment_info)
      @payment_info = payment_info
      @invoice = payment_info.invoice
      @payment_method = payment_info.payment_method
      @errors = payment_info.errors
    end

    def validate
      if payment_info.checkout?
        check_if_has_checkout_payment_info_already
        assign_gateway_info
        try_assign_amount
        check_payment_method_type
      end
    end

    def check_if_has_checkout_payment_info_already
      exist_checkout_payment_info = invoice.payment_infos.checkout.first
      return unless exist_checkout_payment_info
      return if exist_checkout_payment_info == payment_info
      errors.add(:base, 'already have a checkout payment_info')
    end

    def assign_gateway_info
      return unless payment_method

      payment_info.gateway_info = {
        gateway_id: payment_method.payment_gateway.id,
        payment_type: payment_method.payment_type
      }
    end

    def try_assign_amount
      return unless payment_info.amount.zero?
      payment_info.assign_attributes amount: invoice.amount
    end

    def check_payment_method_type
      return unless payment_method

      return if invoice.available_payment_methods.include?(payment_method)
      errors.add(:base, "payment mathod type: #{payment_method.payment_type} is not for Invoice type with #{invoice.invoice_type}")
    end
  end
end
