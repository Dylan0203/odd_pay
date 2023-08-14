require 'rails_helper'

module OddPay
  RSpec.describe PaymentGatewayService::InvoiceUpdater, type: :service do
    subject { PaymentGatewayService::InvoiceUpdater.new(invoice) }

    let(:invoice) { create :invoice, amount: 100 }
    let!(:payment_info) { create :payment_info, invoice: invoice }

    describe '#update' do
      context 'when invoice is partial paid' do
        before do
          invoice.update!(amount: 100)
          payment_info.update!(aasm_state: :paid, amount: 60)
        end

        it 'make it balance_due' do
          subject.update

          expect(invoice.payment_state).to eq 'balance_due'
        end
      end
    end
  end
end
