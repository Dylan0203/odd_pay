# == Schema Information
#
# Table name: odd_pay_payment_infos
#
#  id                    :bigint           not null, primary key
#  invoice_id            :bigint
#  payment_method_id     :bigint
#  merchant_order_number :string
#  aasm_state            :string
#  amount_cents          :integer          default(0), not null
#  amount_currency       :string           default("USD"), not null
#  gateway_info          :jsonb
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  refund_state          :string
#
require 'rails_helper'

module OddPay
  RSpec.describe PaymentInfo, type: :model do
    # associations
    it { should belong_to(:invoice).touch(true).without_validating_presence }
    it { should belong_to(:payment_method).without_validating_presence }
    it { should have_many(:notifications) }
    it { should have_many(:payments) }
    it { should have_many(:refunds) }

    describe '#current_payment_gateway' do
      let(:payment_info) { create :payment_info }

      it 'will return payment_gateway through gateway_info' do
        expect(payment_info.current_payment_gateway).to eq payment_info.payment_method.payment_gateway
      end
    end

    describe '#payment_type' do
      let(:payment_info) { create :payment_info }

      it 'will return symbo payment_type from payment_method' do
        expect(payment_info.payment_type).to eq payment_info.payment_method.payment_type.to_sym
      end
    end

    describe '#generate_post_info' do
      let(:payment_info) { create :payment_info }

      before { payment_info.invoice.update(invoice_state: :completed) }

      it 'will return post form info' do
        post_info = payment_info.generate_post_info

        expect(post_info.class).to eq Hash
        expect(post_info.keys).to match_array(%i(post_url post_params))
      end

      it 'the state will become processing' do
        expect(payment_info.checkout?).to be true

        payment_info.generate_post_info

        expect(payment_info.processing?).to be true
      end

      context 'if there is another paocessing payment_info' do
        let!(:payment_info_2) { create :payment_info, invoice: payment_info.invoice, aasm_state: :processing }

        it 'will become void' do
          expect(payment_info.invoice.payment_infos.processing.size).to be 1 # pretest

          payment_info.generate_post_info

          expect(payment_info_2.reload.void?).to be true
        end
      end

      context 'if invoice is not completed' do
        before { payment_info.invoice.update(invoice_state: :comfirmed) }

        it 'will raise error' do
          expect { payment_info.generate_post_info }.to raise_error OddPay::PaymentInfo::InvalidInvoiceState
        end
      end
    end
  end
end
