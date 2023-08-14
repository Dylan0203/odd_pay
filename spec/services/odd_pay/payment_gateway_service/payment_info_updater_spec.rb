require 'rails_helper'

module OddPay
  RSpec.describe PaymentGatewayService::PaymentInfoUpdater, type: :service do
    subject { PaymentGatewayService::PaymentInfoUpdater.new(payment_info) }

    let(:payment_info) { create :payment_info }
    let!(:notification) { create :notification, payment_info: payment_info, information: info_data, notify_type: :paid }
    let(:current_time) { Time.current }
    let(:info_data) do
      {
        paid_at: current_time.to_s,
        amount: payment_info.invoice.amount.to_f.to_s
      }
    end

    describe '#update' do
      before { payment_info.process! }

      context 'if notificatoin is paid' do
        before { subject.update }

        it 'will changed state to paid' do
          expect(payment_info.paid?).to be true
        end

        it 'will have a payment record with amount and paid time' do
          payment = payment_info.payments.take

          expect(payment.amount).to eq Money.from_amount(notification.information['amount'].to_f)
          expect(payment.started_at.to_i).to eq current_time.to_i
        end
      end

      context 'if incoming amount more than invoice amount' do
        before do
          info_data[:amount] = (payment_info.invoice.amount + Money.from_amount(10)).to_f.to_s
          notification.update! information: info_data
          subject.update
        end

        it 'will changed state to credit_owed' do
          expect(payment_info.credit_owed?).to be true
        end
      end

      context 'if incoming amount less than invoice amount' do
        before do
          info_data[:amount] = (payment_info.invoice.amount - Money.from_amount(10)).to_f.to_s
          notification.update! information: info_data
          subject.update
        end

        it 'will changed state to balance_due' do
          expect(payment_info.balance_due?).to be true
        end
      end

      context 'when invoice type is subscription' do
        before do
          payment_info.invoice.update! subscription_info: {
            period_type: 'months',
            period_point: '01',
            period_times: 99,
            grace_period_in_days: 2
          }
          subject.update
        end

        it 'payment will have ended_at from invoice info' do
          payment = payment_info.payments.take

          expect(payment.ended_at).to eq payment.started_at + 1.months
        end
      end

      context 'if invoice type is normal' do
        before do
          payment_info.invoice.update! invoice_type: :normal
          subject.update
        end

        it 'the payment will have not have ended_at' do
          payment = payment_info.payments.take

          expect(payment.ended_at).to be nil
        end

        it 'run update multiple time will not change result' do
          subject.update

          expect(payment_info.reload.payments.size).to be 1

          subject.update

          expect(payment_info.reload.payments.size).to be 1
        end
      end
    end
  end
end
