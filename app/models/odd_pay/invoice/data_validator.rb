module OddPay
  class Invoice::DataValidator
    attr_reader :invoice, :errors

    ALLOWED_PERIOD_TYPES = %i(days weeks months years).freeze

    def initialize(invoice)
      @invoice = invoice
      @errors = invoice.errors
    end

    def validate
      check_confirmed_info if invoice.confirmed?
    end

    def check_confirmed_info
      check_basic_info
      check_invoice_type
      check_subscription_info if invoice.subscription?
    end

    def check_basic_info
      errors.add(:email, :blank) if invoice.email.blank?
      errors.add(:contact_phone, :blank) if invoice.contact_phone.blank?
      errors.add(:address, :blank) if invoice.address.blank?
    end

    def check_invoice_type
      errors.add(:invoice_type, :blank) if invoice.invoice_type.blank?
    end

    def check_subscription_info
      subscription_info = invoice.subscription_info
      return errors.add(:subscription_info, 'must be a hash format') unless subscription_info.class == Hash

      if !ALLOWED_PERIOD_TYPES.include?(invoice.period_type)
        errors.add(:subscription_info, "`period_type` must be one of #{ALLOWED_PERIOD_TYPES.join(', ')}")
      end

      %i(
        period_point
        period_times
      ).each do |key|
        errors.add(:subscription_info, "`#{key}` must grater than 0") if invoice.send(key) <= 0
      end
    end

    def normalized_item_list
      @normalized_item_list ||= invoice.normalized_item_list
    end
  end
end
