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
end
