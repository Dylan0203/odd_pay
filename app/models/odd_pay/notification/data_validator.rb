module OddPay
  class Notification::DataValidator
    attr_reader :notification, :errors

    ALLOWED_REFERENCES = %w(payment_notify cancel_notify async_payment_notify).freeze

    def initialize(notification)
      @notification = notification
      @errors = notification.errors
    end

    def validate
      check_reference
    end

    def check_reference
      if !ALLOWED_REFERENCES.include?(notification.reference)
        errors.add(:reference, "must be one of #{ALLOWED_REFERENCES.join(', ')}")
      end
    end
  end
end
