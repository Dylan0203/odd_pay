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
        },
        item_list: [item_info_1],
        amount: 100
      }
    end

    let(:item_info_1) do
      { name: 'item_name', quantity: '1', unit_price: '100' }
    end

    shared_context 'success' do
      it 'will save without errors' do
        expect { invoice.save! }.not_to raise_error
      end
    end

    shared_context 'failed' do
      it 'will raise errors' do
        expect { invoice.save! }.to raise_error ActiveRecord::RecordInvalid
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

    describe 'item_list' do
      context 'when list is empty' do
        before { params[:item_list] = [] }

        include_context 'failed'
      end

      %i(
        name
        quantity
        unit_price
      ).each do |key|
        context "if item info missing `#{key}`" do
          before { item_info_1[key] = nil }

          include_context 'failed'
        end
      end
    end
  end
end
