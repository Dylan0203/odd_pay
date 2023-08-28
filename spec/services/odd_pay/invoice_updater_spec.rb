require 'rails_helper'

module OddPay
  RSpec.describe PaymentGatewayService::InvoiceUpdater, type: :service do
    subject { PaymentGatewayService::InvoiceUpdater.new(invoice) }

    let(:invoice) { create :invoice, amount: invoice_amount }
    let(:invoice_amount) { 100 }
    let!(:payment_info) { create :payment_info, invoice: invoice }

    describe '#update' do
      context 'when invoice is partial paid' do
        let(:first_paid_amount) { 60 }

        before do
          invoice.update!(amount: 100)
          payment_info.update!(aasm_state: :paid, amount: first_paid_amount)
          subject.update
        end

        it 'make it balance_due' do
          expect(invoice.payment_state).to eq 'balance_due'
        end

        context 'when invoice is paid too much' do
          let!(:another_payment_info) do
            create :payment_info,
                   invoice: invoice,
                   aasm_state: :paid,
                   amount: invoice_amount
          end

          it 'make it credit_owed' do
            subject.update

            expect(invoice.payment_state).to eq 'credit_owed'
          end
        end

        context 'when invoice is paid' do
          let!(:another_payment_info) do
            create :payment_info,
                   invoice: invoice,
                   aasm_state: :paid,
                   amount: invoice_amount - first_paid_amount
          end

          it 'make it paid' do
            subject.update

            expect(invoice.payment_state).to eq 'paid'
          end
        end
      end
    end
  end
end
