require 'rails_helper'

module OddPay
  RSpec.describe PaymentMethod::DataValidator, type: :model do
    let(:payment_method) { create :payment_method, params }
    let(:params) do
      {
        name: :NewebPay,
        payment_type: :subscription
      }
    end

    shared_context 'success' do
      it 'will save without errors' do
        expect { payment_method.save! }.not_to raise_error
      end
    end

    shared_context 'failed' do
      it 'will raise errors' do
        expect { payment_method.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    include_context 'success'

    %i(
      name
      payment_type
    ).each do |key|
      context "if missing attribute `#{key}`" do
        before { params[key] = nil }

        include_context 'failed'
      end
    end

    context 'if payment_type is not allowed' do
      before { params[:payment_type] = 'not allowed payment_type' }

      include_context 'failed'
    end
  end
end
