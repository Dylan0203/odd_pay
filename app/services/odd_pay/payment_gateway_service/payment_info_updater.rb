module OddPay
  class PaymentGatewayService::PaymentInfoUpdater
    attr_reader :payment_info, :latest_notification, :info, :invoice, :payments

    def initialize(payment_info)
      @payment_info = payment_info
      @latest_notification = payment_info.notifications.has_notify_type.last || OddPay::Notification.new
      @info = latest_notification.information.with_indifferent_access
      @invoice = payment_info.invoice
      @payments = payment_info.payments
    end

    def self.update(payment_info)
      new(payment_info).update
    end

    def update
      process_last_notification
      update_refund_state
    end

    def process_last_notification
      case latest_notification.notify_type.to_sym
      when :paid
        pay_via_payment_type
      when :failed
        payment_info.fail! if payment_info.may_fail?
      when :canceled
        payment_info.cancel! if payment_info.may_cancel?
      when :async_payment_info
        payment_info.wait! if payment_info.may_wait?
      when :refunded, :deauthorized
        try_to_create_refund_record
      when :collected, :current_payment_info
      end
    end

    def update_refund_state
      refunds = payment_info.refunds.done
      return unless refunds.exists?

      balance = payments.sum(:amount_cents) - refunds.sum(:amount_cents)

      if balance > 0
        payment_info.partial_refund! if payment_info.may_partial_refund?
      else
        payment_info.refund! if payment_info.may_refund?
      end
    end

    private

    def pay_via_payment_type
      ActiveRecord::Base.transaction do
        last_payment = payments.last
        current_payment = find_for_create_payment

        return if last_payment == current_payment

        if invoice.subscription?
          current_payment.update!(expired_at: subscription_expired_time)
        end

        payment_info.pay!
      end
    end

    def find_for_create_payment
      payments.find_or_create_by!(
        paid_at: paid_at,
        amount_cents: paid_amount.fractional
      )
    end

    def paid_amount
      Money.from_amount(info[:amount].to_f)
    end

    def paid_at
      @paid_at ||= Time.zone.parse(info[:paid_at])
    end

    def subscription_expired_time
      reference_time = if invoice.expired?
                         paid_at
                       else
                         invoice.expired_at
                       end

      reference_time + invoice.subscription_duration
    end

    def try_to_create_refund_record
      payment_info.refunds.find_or_create_by!(
        amount_cents: Money.from_amount(info[:amount].to_f).fractional,
        aasm_state: :done,
        refunded_at: latest_notification.created_at
      )
    end
  end
end
