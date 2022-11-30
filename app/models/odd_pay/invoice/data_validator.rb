module OddPay
  class Invoice::DataValidator
    attr_reader :invoice, :errors

    ALLOWED_PERIOD_TYPES = %i(days months years).freeze

    def initialize(invoice)
      @invoice = invoice
      @errors = invoice.errors
    end

    def validate
      check_basic_info
      check_item_list
      check_invoice_type
      check_subscription_info if invoice.subscription?
    end

    def check_basic_info
      errors.add(:billing_email, :blank) if invoice.billing_email.blank?
      errors.add(:billing_phone, :blank) if invoice.billing_phone.blank?
      errors.add(:billing_address, :blank) if invoice.billing_address.blank?
    end

    def check_item_list
      return errors.add(:item_list, 'must be an Array format') unless normalized_item_list.class == Array
      return errors.add(:item_list, 'must have at list one item info') if normalized_item_list.blank?
      normalized_item_list.each_with_index do |info, index|
        human_index = index + 1
        errors.add(:item_list, "The #{human_index}th item info missing `name`") if info[:name].blank?
        errors.add(:item_list, "The #{human_index}th item info `quantity` must grater than 0") unless info[:quantity] > 0
        errors.add(:item_list, "The #{human_index}th item info `unit_price` must grater than 0") unless info[:unit_price] > 0
      end
      check_amount
    end

    def check_amount
      sum = normalized_item_list.inject(0) do |amount, info|
        amount + (info[:quantity] * info[:unit_price])
      end

      errors.add(:amount, "incorrect amount") if sum != invoice.amount.to_i
      errors.add(:amount, "amount can not be zero") unless sum > 0
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
        grace_period_in_days
      ).each do |key|
        errors.add(:subscription_info, "`#{key}` must grater than 0") if invoice.send(key) <= 0
      end
    end

    def normalized_item_list
      @normalized_item_list ||= invoice.normalized_item_list
    end
  end
end
