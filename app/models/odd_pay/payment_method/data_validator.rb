module OddPay
  class PaymentMethod::DataValidator
    attr_reader :payment_method, :errors, :payment_gateway

    def initialize(payment_method)
      @payment_method = payment_method
      @errors = payment_method.errors
      @payment_gateway = payment_method.payment_gateway
    end

    def validate
      errors.add(:name, :blank) if payment_method.name.blank?

      check_payment_type
    end

    def check_payment_type
      return unless payment_gateway
      available_payment_types = payment_gateway.available_payment_types
      return if available_payment_types.include?(payment_method.payment_type.try(:to_sym))

      errors.add(:payment_type, "`payment_type` must be one of #{available_payment_types.join(', ')}")
    end
  end
end
