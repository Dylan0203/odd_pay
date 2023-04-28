require 'rails_helper'

module OddPay
  RSpec.describe Invoice::DataValidator, type: :model do
    let(:invoice) { create :invoice, params }
    let(:params) do
      {
        billing_email: 'odd@odd.tw',
        billing_phone: '0987654321',
        billing_address: "odd's address",
        invoice_type: :subscription,
        subscription_info: {
          period_type: 'days',
          period_point: '01',
          period_times: 99,
          grace_period_in_days: 2
        }
      }
    end

    context 'when confirming an invoice' do
      shared_context 'success' do
        it 'will return true' do
          expect(invoice.confirm!).to be_truthy
        end
      end

      shared_context 'failed' do
        it 'will return false' do
          expect(invoice.confirm!).to be_falsey
        end
      end

      include_context 'success'

      %i(
        billing_email
        billing_phone
        billing_address
        invoice_type
        subscription_info
      ).each do |key|
        context "if missing attribute `#{key}`" do
          before { params[key] = nil }

          include_context 'failed'
        end
      end

      describe 'subscription_info' do
        %i(
          period_type
          period_point
          period_times
          grace_period_in_days
        ).each do |key|
          context "if missing data `#{key}`" do
            before { params[:subscription_info][key] = nil }

            include_context 'failed'
          end
        end

        context "when subscription_info has no value but invoice_type is `normal`" do
          before do
            params[:invoice_type] = :normal
            params[:subscription_info] = nil
          end

          include_context 'success'
        end
      end

      describe 'amount' do
        context 'when confirming an invoice' do
          let!(:item_1) { create :invoice_item, invoice: invoice, price: 100 }
          let!(:item_2) { create :invoice_item, invoice: invoice, price: 100 }

          it 'amount will have the same amount from items' do
            invoice.confirm!
            expect(invoice.amount).to eq Money.from_amount(200)
          end
        end
      end
    end
  end
end
