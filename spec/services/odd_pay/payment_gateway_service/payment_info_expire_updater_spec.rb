require 'rails_helper'

module OddPay
  RSpec.describe PaymentGatewayService::PaymentInfoExpireUpdater, type: :service do
    subject { PaymentGatewayService::PaymentInfoExpireUpdater.new(payment_info) }

    let(:payment_info) { create :payment_info }
    let!(:payment) { create :payment, payment_info: payment_info, ended_at: current_time }
    let(:current_time) { Time.current }

    describe '#update' do
      before do
        payment_info.process!
        payment_info.pay!
      end

      context 'if payment is expired' do
        before do
          allow(payment_info.invoice).to receive_messages(grace_period_in_days: 0.days)
          subject.update
        end

        it 'will changed state to overdue' do
          expect(payment_info.overdue?).to be true
        end
      end
    end
  end
end
