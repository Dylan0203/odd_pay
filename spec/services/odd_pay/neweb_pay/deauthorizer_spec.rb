require 'rails_helper'

module OddPay
  RSpec.describe NewebPay::Deauthorizer, type: :service do
    subject { NewebPay::Deauthorizer.new(payment_info) }

    let(:payment_gateway) { create :payment_gateway }
    let(:payment_info) do
      create :payment_info,
             gateway_info: {
               payment_type: :credit_card,
               gateway_id: payment_gateway.id
             },
             aasm_state: :paid,
             amount: 88000
    end

    describe '#call' do
      let(:last_notification) { payment_info.notifications.last }
      let(:response) do
        {
          "Result" => {
            "Amt" => 88000,
            "TradeNo" => "23100217075346683",
            "CheckCode" => "69707BDFB8E56BCE07221510FDFF3D5088BA00C8DF893810A7ECAC1A4932FC39",
            "MerchantID" => "MS344441353",
            "MerchantOrderNo" => "10_1S_S1W9CP"
          },
          "Status" => "SUCCESS",
          "Message" => "放棄授權成功"
        }
      end
      let(:info_result) do
        {
          "amount" => 88000,
          "message" => "放棄授權成功",
          "is_valid" => true,
          "api_succeed" => true,
          "original_info" => {
            "Amt" => 88000,
            "TradeNo" => "23100217075346683",
            "CheckCode" => "69707BDFB8E56BCE07221510FDFF3D5088BA00C8DF893810A7ECAC1A4932FC39",
            "MerchantID" => "MS344441353",
            "MerchantOrderNo" => "10_1S_S1W9CP"
          },
          "response_type" => "deauthorized"
        }
      end

      before do
        allow_any_instance_of(Spgateway::ClientV2).to receive(:credit_card_deauthorize_by_merchant_order_no).and_return(response)
        subject.call
      end

      it 'last notification will has decode info' do
        expect(last_notification.information).to eq info_result
      end

      it 'last notification is notify_type: deauthorized ' do
        expect(last_notification.deauthorized?).to be true
      end

      it 'last notification is reference: deauthorize_notify' do
        expect(last_notification.reference).to eq 'deauthorize_notify'
      end

      context 'when response not success' do
        let(:response) do
          {
            "Result" => {
              "Amt" => 88000,
              "TradeNo" => "23100217075346683",
              "CheckCode" => "69707BDFB8E56BCE07221510FDFF3D5088BA00C8DF893810A7ECAC1A4932FC39",
              "MerchantID" => "MS344441353",
              "MerchantOrderNo" => "10_1S_S1W9CP"
            },
            "Status" => "TRA10047",
            "Message" => "該交易不為授權成功狀態，不可放棄授權"
          }
        end

        let(:info_result) do
          {
            "amount" => 88000,
            "message" => "該交易不為授權成功狀態，不可放棄授權",
            "is_valid" => true,
            "api_succeed" => false,
            "original_info" => {
              "Amt" => 88000,
              "TradeNo" => "23100217075346683",
              "CheckCode" => "69707BDFB8E56BCE07221510FDFF3D5088BA00C8DF893810A7ECAC1A4932FC39",
              "MerchantID" => "MS344441353",
              "MerchantOrderNo" => "10_1S_S1W9CP"
            },
            "response_type" => "init"
          }
        end

        it 'last notification will has decode info' do
          expect(last_notification.information).to eq info_result
        end

        it 'last notification is notify_type: init ' do
          expect(last_notification.init?).to be true
        end
      end
    end
  end
end
