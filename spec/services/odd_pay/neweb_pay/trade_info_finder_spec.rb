require 'rails_helper'

module OddPay
  RSpec.describe NewebPay::TradeInfoFinder, type: :service do
    subject { NewebPay::TradeInfoFinder.new(payment_info) }

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
    let!(:paid_notification) do
      create :notification, payment_info: payment_info,
                            notify_type: :paid,
                            information: {
                              original_info: {
                                Result: {
                                  PeriodNo: :PeriodNo
                                }
                              }
                            }
    end

    describe '#call' do
      let(:last_notification) { payment_info.notifications.last }
      let(:response) do
        {
          "Result" => {
            "Amt" => 15000,
            "ECI" => nil,
            "Auth" => "123235",
            "Inst" => "0",
            "Card4No" => "1111",
            "Card6No" => "400022",
            "PayTime" => "2023-10-01 23:36:02",
            "TradeNo" => "23100123360244142",
            "AuthBank" => "KGI",
            "CloseAmt" => nil,
            "FundTime" => "0000-00-00",
            "InstEach" => "0",
            "CheckCode" => "610C34230903104923CAE74477106D668A12F12A98F9B3C84E87453D039892F7",
            "InstFirst" => "0",
            "BackStatus" => "0",
            "CreateTime" => "2023-10-01 23:36:02",
            "MerchantID" => "MS344441353",
            "RespondMsg" => "授權成功",
            "BackBalance" => "15000",
            "CloseStatus" => "0",
            "PaymentType" => "CREDIT",
            "RespondCode" => "00",
            "TradeStatus" => "3",
            "PaymentMethod" => "CREDIT",
            "MerchantOrderNo" => "Z_1Q_S1UWNI"
          },
          "Status" => "SUCCESS",
          "Message" => "查詢成功"
        }
      end
      let(:info_result) do
        {
          "amount" => 15000,
          "message" => "查詢成功",
          "is_valid" => true,
          "api_succeed" => true,
          "original_info" => {
            "Amt" => 15000,
            "ECI" => nil,
            "Auth" => "123235",
            "Inst" => "0",
            "Card4No" => "1111",
            "Card6No" => "400022",
            "PayTime" => "2023-10-01 23:36:02",
            "TradeNo" => "23100123360244142",
            "AuthBank" => "KGI",
            "CloseAmt" => nil,
            "FundTime" => "0000-00-00",
            "InstEach" => "0",
            "CheckCode" => "610C34230903104923CAE74477106D668A12F12A98F9B3C84E87453D039892F7",
            "InstFirst" => "0",
            "BackStatus" => "0",
            "CreateTime" => "2023-10-01 23:36:02",
            "MerchantID" => "MS344441353",
            "RespondMsg" => "授權成功",
            "BackBalance" => "15000",
            "CloseStatus" => "0",
            "PaymentType" => "CREDIT",
            "RespondCode" => "00",
            "TradeStatus" => "3",
            "PaymentMethod" => "CREDIT",
            "MerchantOrderNo" => "Z_1Q_S1UWNI"
          },
          "response_type" => "current_payment_info"
        }
      end

      before do
        allow_any_instance_of(Spgateway::ClientV2).to receive(:query_trade_info).and_return(response)
        subject.call
      end

      it 'last notification will has decode info' do
        expect(last_notification.information).to eq info_result
      end

      it 'last notification is notify_type: current_payment_info ' do
        expect(last_notification.current_payment_info?).to be true
      end

      it 'last notification is reference: payment_info_notify' do
        expect(last_notification.reference).to eq 'payment_info_notify'
      end

      context 'when response not success' do
        let(:response) do
          {
            "Result" => [],
            "Status" => "TRA10021",
            "Message" => "查無交易資料:12"
          }
        end

        let(:info_result) do
          {
            "message" => "查無交易資料:12",
            "is_valid" => true,
            "api_succeed" => false,
            "original_info" => {},
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
