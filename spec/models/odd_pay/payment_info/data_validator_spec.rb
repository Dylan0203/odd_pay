require 'rails_helper'

module OddPay
  RSpec.describe PaymentInfo::DataValidator, type: :model do
    let(:payment_info) { create :payment_info }

    shared_context 'success' do
      it 'will save without errors' do
        expect { payment_info.save! }.not_to raise_error
      end
    end

    shared_context 'failed' do
      it 'will raise errors' do
        expect { payment_info.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    include_context 'success'

    context 'if no payment_method given' do
      before { payment_info.assign_attributes(payment_method: nil) }

      include_context 'failed'
    end

    context 'if there is an checkout payment_info already' do
      let(:checkout_payment_info) { create :payment_info }

      before { payment_info.assign_attributes(invoice: checkout_payment_info.invoice) }

      include_context 'failed'
    end

    it 'gateway_info will have gateway id' do
      expect(payment_info.gateway_info['gateway_id']).to eq payment_info.payment_method.payment_gateway.id
    end

    it 'gateway_info will have payment_type' do
      expect(payment_info.gateway_info['payment_type']).to eq payment_info.payment_method.payment_type
    end

    context 'when payment info is not checkout' do
      let!(:another_payment_method) { create :payment_method }

      before { payment_info.assign_attributes(payment_method: another_payment_method) }

      it 'gateway_info will not change' do
        expect(payment_info.gateway_info['gateway_id']).not_to eq payment_info.payment_method.payment_gateway.id
      end
    end

    it 'amount will be same as invoice amount' do
      expect(payment_info.amount).to eq payment_info.invoice.amount
    end
  end
end
