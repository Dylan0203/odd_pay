module OddPay
  class PaymentGatewayService::PaymentInfoExpireUpdater
    attr_reader :payment_info, :last_payment, :invoice

    def initialize(payment_info)
      @payment_info = payment_info
      @last_payment = payment_info.payments.last
      @invoice = payment_info.invoice
    end

    def self.update(payment_info)
      new(payment_info).update
    end

    def update
      return if payment_info.overdue?
      return unless last_payment

      payment_info.expire! if is_overdue?
    end

    def is_overdue?
      return false unless expired_at

      (expired_at + grace_period_in_days) <= Time.current
    end

    def expired_at
      @expired_at ||= last_payment.ended_at
    end

    def grace_period_in_days
      invoice.grace_period_in_days
    end
  end
end
