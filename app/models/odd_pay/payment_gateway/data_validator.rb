module OddPay
  class PaymentGateway::DataValidator
    attr_reader :payment_gateway, :errors, :gateway_provider, :gateway_info

    def initialize(payment_gateway)
      @payment_gateway = payment_gateway
      @errors = payment_gateway.errors
      @gateway_provider = payment_gateway.gateway_provider.try(:to_sym)
      @gateway_info = payment_gateway.gateway_info || {}
    end

    def validate
      check_gateway_provider
      check_gateway_info
      try_archive_gateway_info_to_history
    end

    def check_gateway_provider
      available_providers = OddPay::PaymentGatewayService::AVAILABLE_GATEWAYS
      return if available_providers.include?(gateway_provider)

      errors.add(:gateway_provider, "`gateway_provider` must be one of #{available_providers.join(', ')}")
    end

    def check_gateway_info
      case gateway_provider
      when :NewebPay
        check_neweb_pay_gateway_info
      end
    end

    def check_neweb_pay_gateway_info
      %w(
        hash_iv
        hash_key
        merchant_id
      ).each do |key|
        if gateway_info[key].blank?
          errors.add(:gateway_info, "missing `#{key}` for #{gateway_provider}")
        end
      end
    end

    def try_archive_gateway_info_to_history
      return unless payment_gateway.gateway_info_changed?

      new_info = payment_gateway.gateway_info_was
      return if new_info.blank?

      payment_gateway.historical_gateway_info.push(new_info)
    end
  end
end
