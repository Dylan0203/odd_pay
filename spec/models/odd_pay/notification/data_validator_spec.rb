require 'rails_helper'

module OddPay
  RSpec.describe Notification::DataValidator, type: :model do
    let(:notification) { create :notification, params }
    let(:params) do
      {
        reference: :payment_notify
      }
    end

    shared_context 'success' do
      it 'will save without errors' do
        expect { notification.save! }.not_to raise_error
      end
    end

    shared_context 'failed' do
      it 'will raise errors' do
        expect { notification.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    include_context 'success'

    context 'if reference not allowed' do
      before { params[:reference] = 'not allowed reference' }

      include_context 'failed'
    end
  end
end
