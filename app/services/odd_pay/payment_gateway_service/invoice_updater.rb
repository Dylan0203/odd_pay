module OddPay
  class PaymentGatewayService::InvoiceUpdater
    attr_reader :invoice, :latest_payment_info

    def initialize(invoice)
      @invoice = invoice
      @latest_payment_info = invoice.payment_infos.last
    end

    def self.update(payment_info)
      new(payment_info).update
    end

    def update
      case latest_payment_info.aasm_state.to_sym
      when :paid
        update_payment_state
      when :overdue
        invoice.expire! unless invoice.overdue?
      when :canceled
        invoice.cancel! unless invoice.canceled?
      end
    end

    def update_payment_state
      balance = invoice.unpaid_amount
      case
      when balance.zero?
        invoice.pay! unless invoice.paid?
      when balance > 0
        invoice.balance_owe! unless invoice.balance_due?
      when balance < 0
        invoice.credit_owe! unless invoice.credit_owed?
      end
    end
  end
end
