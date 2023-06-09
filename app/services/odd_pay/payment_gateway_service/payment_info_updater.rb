module OddPay
  class PaymentGatewayService::PaymentInfoUpdater
    attr_reader :payment_info, :latest_notification, :info, :invoice

    def initialize(payment_info)
      @payment_info = payment_info
      @latest_notification = payment_info.notifications.has_notify_type.last
      @info = latest_notification.information.with_indifferent_access
      @invoice = payment_info.invoice
    end

    def self.update(payment_info)
      new(payment_info).update
    end

    def update
      case latest_notification.notify_type.to_sym
      when :paid
        pay_via_payment_type if payment_info.may_pay?
      when :failed
        payment_info.fail! unless payment_info.failed?
      when :canceled
        payment_info.cancel! unless payment_info.canceled?
      when :async_payment_info
        payment_info.wait!
      end
    end

    private

    def pay_via_payment_type
      ActiveRecord::Base.transaction do
        if invoice.subscription?
          process_subscription_payment
        else
          find_for_create_payment
        end

        balance = paid_amount - payment_info.amount

        if balance.zero?
          payment_info.pay!
        elsif balance < 0
          payment_info.balance_owe!
        elsif balance > 0
          payment_info.credit_owe!
        end
      end
    end

    def find_for_create_payment
      payments.find_or_create_by!(
        started_at: paid_at,
        amount_cents: paid_amount.fractional
      )
    end

    def process_subscription_payment
      last_payment = payments.last

      current_payment = find_for_create_payment

      return if last_payment == current_payment

      current_payment.update!(ended_at: expired_time(last_payment))
    end

    def payments
      payment_info.payments
    end

    def paid_amount
      Money.from_amount(info[:amount].to_f)
    end

    def paid_at
      @paid_at ||= Time.zone.parse(info[:paid_at])
    end

    def expired_time(last_payment)
      expired_at = last_payment.try(:ended_at)

      is_new_period = !expired_at || (expired_at + invoice.grace_period_in_days) <= Time.current
      return paid_at + validity_period if is_new_period

      expired_at + validity_period
    end

    def validity_period
      type = invoice.period_type
      return 1.send(type) if type != :days

      invoice.period_point.send(type)
    end
  end
end
