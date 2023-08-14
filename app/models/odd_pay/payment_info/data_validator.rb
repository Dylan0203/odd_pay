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

        return unless payment_method

        assign_gateway_info
        assign_unpaid_amount
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
      payment_info.gateway_info = {
        gateway_id: payment_method.payment_gateway.id,
        payment_type: payment_method.payment_type
      }
    end

    def assign_unpaid_amount
      payment_info.assign_attributes amount: amount
    end

    def check_payment_method_type
      return if invoice.available_payment_methods.include?(payment_method)
      errors.add(:base, "payment mathod type: #{payment_method.payment_type} is not for Invoice type with #{invoice.invoice_type}")
    end

    def unpaid_amount
      @unpaid_amount ||= invoice.unpaid_amount
    end

    def amount
      map = OddPay::PaymentGatewayService::PAYMENT_TYPE_AMOUNT_LIMIT_MAP[
        payment_method.
        payment_gateway.
        gateway_provider.
        to_sym
      ] || {}

      limit = Money.from_amount(
        map[payment_method.payment_type.to_sym] ||
          map[:default] ||
          0
      )

      return unpaid_amount if limit.zero?

      [unpaid_amount, limit].min
    end
  end
end
