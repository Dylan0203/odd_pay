require 'rails_helper'

module OddPay
  RSpec.describe Invoice::DataValidator, type: :model do
    let(:invoice) { create :invoice, params }
    let(:params) do
      {
        email: 'odd@odd.tw',
        contact_phone: '0987654321',
        address: { street: "odd's address" },
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
        email
        contact_phone
        address
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
    end
  end
end
