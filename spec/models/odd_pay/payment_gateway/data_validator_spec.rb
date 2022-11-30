require 'rails_helper'

module OddPay
  RSpec.describe PaymentGateway::DataValidator, type: :model do
    let(:payment_gateway) { create :payment_gateway, params }
    let(:params) do
      {
        gateway_provider: :NewebPay,
        gateway_info: {
          hash_iv: 'hash_iv',
          hash_key: 'hash_key',
          merchant_id: 'merchant_id'
        }
      }
    end

    shared_context 'success' do
      it 'will save without errors' do
        expect { payment_gateway.save! }.not_to raise_error
      end
    end

    shared_context 'failed' do
      it 'will raise errors' do
        expect { payment_gateway.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    include_context 'success'

    %i(
      gateway_provider
      gateway_info
    ).each do |key|
      context "if missing attribute `#{key}`" do
        before { params[key] = nil }

        include_context 'failed'
      end
    end

    context 'if gateway_provider is not allowed' do
      before { params[:gateway_provider] = 'newwebPay' }

      include_context 'failed'
    end

    describe '#check_gateway_info' do
      describe 'when provider is NewwebPay' do
        before { params[:gateway_provider] = 'NewebPay' }

        %i(
          hash_iv
          hash_key
          merchant_id
        ).each do |key|
          context "if missing data `#{key}`" do
            before { params[:gateway_info][key] = nil }

            include_context 'failed'
          end
        end
      end
    end

    describe '#try_archive_gateway_info_to_history' do
      context 'when gateway_provider update with same value' do
        let!(:original_data_size) { payment_gateway.historical_gateway_info.size }

        it 'historical_gateway_info will not change' do
          payment_gateway.update!(params)

          expect(payment_gateway.historical_gateway_info.size).to be original_data_size
        end

        it 'old info will push into `gateway_info_to_history`' do
          original_info = payment_gateway.gateway_info
          new_info = {
            hash_iv: 'new_hash_iv',
            hash_key: 'new_hash_key',
            merchant_id: 'new_merchant_id'
          }

          payment_gateway.update!(gateway_info: new_info)

          expect(payment_gateway.historical_gateway_info.size).to be original_data_size + 1
          expect(payment_gateway.historical_gateway_info.last).to eq original_info
        end
      end
    end
  end
end
