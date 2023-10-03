module OddPay
  class PaymentGatewayService::InvoiceUpdater
    attr_reader :invoice # , :payments

    def initialize(invoice)
      @invoice = invoice
    end

    def self.update(payment_info)
      new(payment_info).update
    end

    def update
      update_payment_state
      update_shipment_state
    end

    def update_payment_state
      balance = invoice.amount - invoice.paid_amount

      case
      when balance.zero?
        pay_and_record_paid_at
      when balance > 0
        balance_due_or_overdue
      when balance < 0
        invoice.credit_owe! unless invoice.credit_owed?
      end
    end

    def pay_and_record_paid_at
      last_payment = invoice.payments.last
      last_paid_at = last_payment.paid_at

      if invoice.paid_at != last_paid_at
        invoice.assign_attributes(
          paid_at: last_paid_at,
          expired_at: last_payment.expired_at
        )
        invoice.pay!
      end
    end

    def balance_due_or_overdue
      if invoice.paid?
        return unless invoice.expired?

        invoice.expire! unless invoice.overdue?
      else
        invoice.balance_owe! unless invoice.balance_due?
      end
    end

    def update_shipment_state; end
  end
end
