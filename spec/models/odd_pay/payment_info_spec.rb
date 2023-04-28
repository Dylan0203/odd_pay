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
#
require 'rails_helper'

module OddPay
  RSpec.describe PaymentInfo, type: :model do
    # associations
    it { should belong_to(:invoice).touch(true).without_validating_presence }
    it { should belong_to(:payment_method).without_validating_presence }
    it { should have_many(:notifications) }
    it { should have_many(:payments) }

    describe 'scopes' do
      describe '.expired' do
        subject { PaymentInfo.expired }

        let(:invoice) { create :invoice, invoice_type: :subscription }
        let(:payment_info) { create :payment_info, invoice: invoice, aasm_state: :paid }
        let(:now) { Time.current }
        let(:tomorrow) { now.next_day }
        let!(:payment) { create :payment, payment_info: payment_info, ended_at: tomorrow }

        shared_context 'payment_info is Not in the expired scope' do
          it 'payment_info is Not in the expired scope' do
            expect(subject).to match_array []
          end
        end

        shared_context 'payment_info is in the expired scope' do
          it 'payment_info is in the expired scope' do
            expect(subject).to match_array [payment_info]
          end
        end

        context 'if payment_info has vaild payment' do
          include_context 'payment_info is Not in the expired scope'
        end

        context 'if payment_info has expired payment' do
          before { payment.update! ended_at: now }

          include_context 'payment_info is in the expired scope'

          context 'multiple valid payments still get one payment_info' do
            before { payment_info.payments.create!(ended_at: now) }

            include_context 'payment_info is in the expired scope'
          end
        end
      end
    end
  end

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

    before { payment_info.invoice.confirm! }

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

    context 'if invoice is not confirm' do
      before { payment_info.invoice.back_to_check_out! }

      it 'will raise error' do
        expect { payment_info.generate_post_info }.to raise_error OddPay::PaymentInfo::InvalidInvoiceState
      end
    end
  end

  describe 'private methods' do
    describe '#ignore_processing_payment_infos' do
      let!(:payment_info_1) { create :payment_info, aasm_state: :processing }
      let!(:payment_info_2) { create :payment_info, invoice: payment_info_1.invoice, aasm_state: :processing }

      it 'all processing payment_infos will become void' do
        expect(payment_info_1.invoice.payment_infos.processing.size).to be 2 # pretest

        payment_info_1.send(:ignore_processing_payment_infos)

        expect(payment_info_1.invoice.payment_infos.processing.size).to be 1
      end
    end
  end
end
