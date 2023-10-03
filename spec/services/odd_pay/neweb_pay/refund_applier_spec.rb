require 'rails_helper'

module OddPay
  RSpec.describe NewebPay::RefundApplier, type: :service do
    subject { NewebPay::RefundApplier.new(payment_info) }

    let(:payment_gateway) { create :payment_gateway }
    let(:payment_info) do
      create :payment_info,
             gateway_info: {
               payment_type: :wechat_pay,
               gateway_id: payment_gateway.id
             },
             aasm_state: :paid,
             amount: 88000
    end
    let(:last_notification) { payment_info.notifications.last }

    describe '#call' do
      let(:response) do
        {
          "UID" => "MS344441353",
          "Status" => "1000",
          "Message" => "退款申請完成",
          "Version" => "1.0",
          "Encoding" => "",
          "HashData" => "DF5ACA8D986F22F0613A79C0747B80975C2821F2F22A752DBF50293015802D0C",
          "EncryptData" => "e673faa1d9d49b7c206aa56e933e7f2161bbf06828a9926a746f54439fa27d748327157f69991cbb300a7becf0d5db24ec13b881b74eb8c670c8be1bf5ca6a27f5012288aff075640b7fd761a9fa946c1a3c85e20ed287e33971632af1ff0d17ea2a97fa345de2e1c04199da7af2f2b08ecebccb30a7c54c0c7e18fd7d3e4924243e32061ee9118d2ad1c299ead3aff324d2c1c26acf1cfc85157b7c6ec5c7d0"
        }
      end
      let(:info_result) do
        {
          "message" => "退款申請完成",
          "is_valid" => true,
          "api_succeed" => true,
          "original_info" => {
            "TradeNo" => "23100217320445455",
            "BankCode" => "",
            "RefundDate" => "2023-10-02 17:33:06",
            "BankMessage" => "",
            "RefundAmount" => 88000,
            "MerchantOrderNo" => "13_1U_S1WAHB"
          },
          "response_type" => "refunded"
        }
      end

      context 'when payment type is one of ewallet' do
        before do
          allow_any_instance_of(Spgateway::ClientV2).to receive(:ewallet_refund_by_merchant_order_no).and_return(response)
          subject.call
        end

        it 'last notification will has decode info' do
          expect(last_notification.information).to eq info_result
        end

        it 'last notification is notify_type: refunded ' do
          expect(last_notification.refunded?).to be true
        end

        it 'last notification is reference: refund_notify' do
          expect(last_notification.reference).to eq 'refund_notify'
        end

        context 'when response not success' do
          let(:response) do
            {
              "UID" => "MS344441353",
              "Status" => "1105",
              "Message" => "可退金額不足",
              "Version" => "1.0",
              "Encoding" => "",
              "HashData" => "",
              "EncryptData" => ""
            }
          end

          let(:info_result) do
            {
              "message" => "可退金額不足",
              "is_valid" => true,
              "api_succeed" => false,
              "original_info" => {
                "UID" => "MS344441353",
                "Status" => "1105",
                "Message" => "可退金額不足",
                "Version" => "1.0",
                "Encoding" => "",
                "HashData" => "",
                "EncryptData" => ""
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

      context 'when payment type is credit card base payment' do
        let(:response) do
          {
            "Result" => {
              "Amt" => 88000,
              "TradeNo" => "23100217225246746",
              "MerchantID" => "MS344441353",
              "MerchantOrderNo" => "12_1T_S1WA1N"
            },
            "Status" => "SUCCESS",
            "Message" => "退款資料新增成功_模擬信用卡退款成功"
          }
        end

        let(:info_result) do
          {
            "amount" => 88000,
            "message" => "退款資料新增成功_模擬信用卡退款成功",
            "is_valid" => true,
            "api_succeed" => true,
            "original_info" => {
              "Result" => {
                "Amt" => 88000,
                "TradeNo" => "23100217225246746",
                "MerchantID" => "MS344441353",
                "MerchantOrderNo" => "12_1T_S1WA1N"
              },
              "Status" => "SUCCESS",
              "Message" => "退款資料新增成功_模擬信用卡退款成功"
            },
            "response_type" => "refunded"
          }
        end

        before do
          allow_any_instance_of(Spgateway::ClientV2).to receive(:credit_card_refund_by_merchant_order_no).and_return(response)
          payment_info.update!(gateway_info: {
            payment_type: :credit_card,
            gateway_id: payment_gateway.id
          })
          subject.call
        end

        it 'last notification will has decode info' do
          expect(last_notification.information).to eq info_result
        end

        it 'last notification is notify_type: refunded ' do
          expect(last_notification.refunded?).to be true
        end

        it 'last notification is reference: refund_notify' do
          expect(last_notification.reference).to eq 'refund_notify'
        end

        context 'when response not success' do
          let(:response) do
            {
              "Result" => {
                "Amt" => 15000,
                "TradeNo" => "23100219513748323",
                "MerchantID" => "MS344441353",
                "MerchantOrderNo" => "15_20_S1WGXR"
              },
              "Status" => "TRA10036",
              "Message" => "已超過剩餘可退款金額，請確認"
            }
          end

          let(:info_result) do
            {
              "amount" => 15000,
              "message" => "已超過剩餘可退款金額，請確認",
              "is_valid" => true,
              "api_succeed" => false,
              "original_info" => {
                "Result" => {
                  "Amt" => 15000,
                  "TradeNo" => "23100219513748323",
                  "MerchantID" => "MS344441353",
                  "MerchantOrderNo" => "15_20_S1WGXR"
                },
                "Status" => "TRA10036",
                "Message" => "已超過剩餘可退款金額，請確認"
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
end
