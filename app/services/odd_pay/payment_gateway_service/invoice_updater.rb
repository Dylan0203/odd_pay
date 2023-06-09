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
        invoice.pay! unless invoice.paid?
      when :overdue
        invoice.expire! unless invoice.overdue?
      when :canceled
        invoice.cancel! unless invoice.canceled?
      end
    end
  end
end
