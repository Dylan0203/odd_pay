require 'rails_helper'

module OddPay
  RSpec.describe PaymentGatewayService::InvoiceUpdater, type: :service do
    subject { PaymentGatewayService::InvoiceUpdater.new(invoice) }

    let(:invoice) { create :invoice, amount: invoice_amount, invoice_type: :normal }
    let(:payment_info) { create :payment_info, aasm_state: :paid, invoice: invoice }
    let(:invoice_amount) { 100 }
    let(:first_paid_amount) { 60 }
    let(:current_time) { Time.current }

    describe '#update' do
      describe 'update_payment_state' do
        context 'when invoice is partial paid' do
          before { payment_info.payments.create!(amount: first_paid_amount, paid_at: current_time) }

          it 'will be balance_due' do
            subject.update

            expect(invoice.payment_state).to eq 'balance_due'
          end

          context 'when invoice is paid too much' do
            let!(:another_payment_info) { create :payment_info, aasm_state: :paid, invoice: invoice }

            before { another_payment_info.payments.create!(amount: invoice_amount, paid_at: current_time) }

            it 'will be credit_owed' do
              subject.update

              expect(invoice.payment_state).to eq 'credit_owed'
            end
          end

          context 'when invoice is paid' do
            let!(:another_payment_info) { create :payment_info, aasm_state: :paid, invoice: invoice }
            let(:expired_at) { current_time + 1.days }

            before { another_payment_info.payments.create!(amount: invoice_amount - first_paid_amount, paid_at: current_time, expired_at: expired_at) }

            it 'will be paid' do
              subject.update

              expect(invoice.payment_state).to eq 'paid'
            end

            it 'will record paid_at and expired_at on invoice' do
              subject.update

              expect(invoice.paid_at.to_s).to eq current_time.to_s
              expect(invoice.expired_at.to_s).to eq expired_at.to_s
            end
          end
        end
      end
    end
  end
end
