require 'rails_helper'

module OddPay
  RSpec.describe NewebPay::Collector, type: :service do
    subject { NewebPay::Collector.new(payment_info) }

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
          "Amt" => "88000",
          "Status" => "SUCCESS",
          "Message" => "請款資料新增成功_模擬信用卡請款成功",
          "TradeNo" => "23100122364443997",
          "MerchantID" => "MS344441353",
          "MerchantOrderNo" => "W_1N_S1UTWH"
        }
      end
      let(:info_result) do
        {
          "amount" => "88000",
          "api_succeed" => true,
          "message" => "請款資料新增成功_模擬信用卡請款成功",
          "is_valid" => true,
          "original_info" => {
            "Amt" => "88000",
            "Status" => "SUCCESS",
            "Message" => "請款資料新增成功_模擬信用卡請款成功",
            "TradeNo" => "23100122364443997",
            "MerchantID" => "MS344441353",
            "MerchantOrderNo" => "W_1N_S1UTWH"
          },
          "response_type" => "collected"
        }
      end

      before do
        allow_any_instance_of(Spgateway::ClientV2).to receive(:credit_card_collect_by_merchant_order_no).and_return(response)
        subject.call
      end

      it 'last notification will has decode info' do
        expect(last_notification.information).to eq info_result
      end

      it 'last notification is notify_type: collected ' do
        expect(last_notification.collected?).to be true
      end

      it 'last notification is reference: collect_notify' do
        expect(last_notification.reference).to eq 'collect_notify'
      end

      context 'when response not success' do
        let(:response) do
          {
            "Result" => {
              "Amt" => 88000,
              "TradeNo" => "23100217225246746",
              "MerchantID" => "MS344441353",
              "MerchantOrderNo" => "12_1T_S1WA1N"
            },
            "Status" => "TRA10027",
            "Message" => "此訂單已申請過請款，不可重覆請款"
          }
        end

        let(:info_result) do
          {
            "amount" => 88000,
            "message" => "此訂單已申請過請款，不可重覆請款",
            "is_valid" => true,
            "api_succeed" => false,
            "original_info" => {
              "Result" => {
                "Amt" => 88000,
                "TradeNo" => "23100217225246746",
                "MerchantID" => "MS344441353",
                "MerchantOrderNo" => "12_1T_S1WA1N"
              },
              "Status" => "TRA10027",
              "Message" => "此訂單已申請過請款，不可重覆請款"
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
