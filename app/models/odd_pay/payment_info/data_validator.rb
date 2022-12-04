module OddPay
  class PaymentInfo::DataValidator
    attr_reader :payment_info, :invoice, :errors

    def initialize(payment_info)
      @payment_info = payment_info
      @invoice = payment_info.invoice
      @errors = payment_info.errors
    end

    def validate
      if payment_info.checkout?
        check_if_has_checkout_payment_info_already
        assign_gateway_info
        assign_amount
      end
    end

    def check_if_has_checkout_payment_info_already
      exist_checkout_payment_info = invoice.payment_infos.checkout.first
      return unless exist_checkout_payment_info
      return if exist_checkout_payment_info == payment_info
      errors.add(:base, 'already have a checkout payment_info')
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
