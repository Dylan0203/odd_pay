require 'rails_helper'

module OddPay
  RSpec.describe PaymentGatewayService::PaymentInfoUpdater, type: :service do
    subject { PaymentGatewayService::PaymentInfoUpdater.new(payment_info) }

    let(:payment_info) { create :payment_info, aasm_state: :processing, amount: amount }
    let!(:notification) { create :notification, payment_info: payment_info, information: information, notify_type: notify_type }
    let(:current_time) { Time.current }
    let(:notify_type) { :init }
    let(:information) { {} }
    let(:amount) { 100 }

    describe '#update' do
      before { subject.update }

      describe 'aasn_state' do
        context 'when last notification is paid' do
          let(:notify_type) { :paid }
          let(:information) do
            {
              paid_at: current_time.to_s,
              amount: amount.to_f.to_s
            }
          end

          it 'will change state to paid' do
            expect(payment_info.paid?).to be true
          end

          it "will only generate payment record with amount" do
            subject.update
            subject.update

            expect(payment_info.payments.count).to eq 1
            expect(payment_info.payments.take.amount.to_i).to eq amount
          end

          it "the payment will have expired_at when invoice is subscription" do
            expect(payment_info.payments.take.expired_at).not_to be_nil
            expect(payment_info.invoice.subscription_duration > 0.days).to be true
            subscription_expired_at = (current_time + payment_info.invoice.subscription_duration).to_s
            expect(payment_info.payments.take.expired_at.to_s).to eq(subscription_expired_at)
          end

          context 'if the invoice is not subscription' do
            before do
              payment_info.invoice.update! invoice_type: :normal
              payment_info.payments.destroy_all
              subject.update
            end

            it 'the payment will not have expired time' do
              expect(payment_info.payments.take.expired_at).to be_nil
            end
          end
        end

        context 'when last notification is async_payment_info' do
          let(:notify_type) { :async_payment_info }

          it 'will change state to waiting_async_payment' do
            expect(payment_info.waiting_async_payment?).to be true
          end
        end

        context 'when last notification is failed' do
          let(:notify_type) { :failed }

          it 'will change state to failed' do
            expect(payment_info.failed?).to be true
          end
        end

        context 'when last notification is refunded' do
          let(:notify_type) { :refunded }
          let(:information) do
            {
              amount: amount.to_f.to_s
            }
          end

          it 'will only generate refund record' do
            subject.update
            subject.update

            expect(payment_info.refunds.count).to eq 1
            expect(payment_info.refunds.take.amount.to_i).to eq amount
          end

          context 'when last notification is deauthorized' do
            let(:notify_type) { :deauthorized }
            let(:information) do
              {
                amount: amount.to_f.to_s
              }
            end

            it 'will only generate refund record' do
              subject.update
              subject.update

              expect(payment_info.refunds.count).to eq 1
              expect(payment_info.refunds.take.amount.to_i).to eq amount
            end
          end
        end
      end

      describe 'refund_state' do
        context 'when refund is partially' do
          let!(:payment) { create :payment, amount: amount, payment_info: payment_info }
          let!(:refund) { create :refund, amount: amount - 10, payment_info: payment_info, aasm_state: :done, refunded_at: Time.current }

          it 'will change state to partial_refunded' do
            subject.update
            expect(payment_info.partial_refunded?).to be true
          end

          context 'if full another refund has create but not done' do
            let!(:another_refund) { create :refund, amount: 10, payment_info: payment_info, refunded_at: Time.current }

            it 'will still be partial_refunded' do
              subject.update
              expect(payment_info.partial_refunded?).to be true
            end

            it 'will be refunded' do
              another_refund.complete!

              subject.update

              expect(payment_info.refunded?).to be true
            end
          end
        end
      end
    end
  end
end
