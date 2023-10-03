require 'rails_helper'

module OddPay
  RSpec.describe NewebPay::SubscriptionCanceler, type: :service do
    subject { NewebPay::SubscriptionCanceler.new(payment_info) }

    let(:payment_gateway) { create :payment_gateway }
    let(:payment_info) do
      create :payment_info,
             gateway_info: {
               payment_type: :subscription,
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
          "period" => "6e0cd0eff10334d270ff9aac84a43ea89bff0bbdbafe266f4629c0fe0ba278b365521415c5e91452353732fc746102a14f64d90ea0f4fdc945cc858b3b488d25ea2256ca3b3dd1e3c9b95022086c3b4f26f89b9f325c3130a478a04267740c7b607298119f148401dcd50427fbd52f777c48b4b971ee2558d497bb7fcf363026c7db45687bd3b458438866950f3d575ff84a7a4530f6c182947f9d19400cc66699a33decc7e4091abc556f961133f6575c9cc7ad39b735ee6fe3b6e3262c1a4b65b71d81e3b8c9976ea5b695bb050870fe12649c2f8aca2d869dcaf60e814904"
        }
      end
      let(:info_result) do
        {
          "message" => "該定期定額委託單終止成功",
          "is_valid" => true,
          "api_succeed" => true,
          "original_info" => {
            "Result" => {
              "PeriodNo" => "P231002001624kR7M2L",
              "AlterType" => "terminate",
              "MerOrderNo" => "X_1R_S1UYIR"
            },
            "Status" => "SUCCESS",
            "Message" => "該定期定額委託單終止成功"
          },
          "response_type" => "canceled"
        }
      end

      before do
        allow_any_instance_of(Spgateway::ClientV2).to receive(:change_subscription_status).and_return(response)
        subject.call
      end

      it 'last notification will has decode info' do
        expect(last_notification.information).to eq info_result
      end

      it 'last notification is notify_type: canceled ' do
        expect(last_notification.canceled?).to be true
      end

      it 'last notification is reference: cancel_notify' do
        expect(last_notification.reference).to eq 'cancel_notify'
      end

      context 'when response not success' do
        let(:response) do
          {
            "period" => "ad642829ab9d07005673b081de24c46bfbbe869b2b0da33a1a4b45af861eb608c8606b563f00ee029b2b208b076ffa296227d55805287e4343907b9d14e8f24a71f31a4ceb45ceb38e52e87ee226a7f7ae25dfe98939dcbf536cb42231f1a6ba1d7b037000f4cd14b1af8419c275267a3eff29fb3ce7bcd4efed2e4379c23d2db767d989f928caab09cab4f0da28cb8e18734e3f0442a2c7ffa54eb1d0c0762e76d709942529722b48a61dec7aabfd5928f27d2d0b2bc8dbd066388998f5d29d7b3024e8dfc7a1e9851ac10201455dea30bca3f4fd2849a2f65a9121576cb0848fbd49191c8825c2db47c96b79340475af37e0f0c7a360ecd9d3f0eb8f42ecd6"
          }
        end

        let(:info_result) do
          {
            "message" => "不允許此IP執行IP:118.165.19.123",
            "is_valid" => true,
            "api_succeed" => false,
            "original_info" => {
              "Result" => {
                "Version" => "1.0",
                "PeriodNo" => "P231002001624kR7M2L",
                "AlterType" => "terminate",
                "TimeStamp" => "1696256741",
                "MerOrderNo" => "X_1R_S1UYIR",
                "RespondType" => "JSON"
              },
              "Status" => "PER10073",
              "Message" => "不允許此IP執行IP:118.165.19.123"
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
