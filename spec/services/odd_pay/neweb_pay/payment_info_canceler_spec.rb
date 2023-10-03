require 'rails_helper'

module OddPay
  RSpec.describe NewebPay::PaymentInfoCanceler, type: :service do
    subject { NewebPay::PaymentInfoCanceler.new(payment_info) }

    let(:payment_info) { create :payment_info }
    let(:invoice) { payment_info.invoice }
    let(:encode_response) do
      {
        "period" => "6e0cd0eff10334d270ff9aac84a43ea89bff0bbdbafe266f4629c0fe0ba278b365521415c5e91452353732fc746102a14f64d90ea0f4fdc945cc858b3b488d25ea2256ca3b3dd1e3c9b95022086c3b4f26f89b9f325c3130a478a04267740c7b607298119f148401dcd50427fbd52f777c48b4b971ee2558d497bb7fcf363026c7db45687bd3b458438866950f3d575ff84a7a4530f6c182947f9d19400cc66699a33decc7e4091abc556f961133f6575c9cc7ad39b735ee6fe3b6e3262c1a4b65b71d81e3b8c9976ea5b695bb050870fe12649c2f8aca2d869dcaf60e814904"
      }
    end
    let(:decode_data) do
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

    describe '#call' do
      let!(:paid_notification) { create :notification, payment_info: payment_info, information: { "original_info": { "Result[PeriodNo]": 123 } }, notify_type: :paid }
      let(:last_notification) { payment_info.notifications.last }

      before do
        allow_any_instance_of(Spgateway::ClientV2).to receive(:change_subscription_status).and_return(encode_response)
        payment_info.update!(aasm_state: :paid)
        invoice.update!(
          payment_state: :paid,
          invoice_state: :completed
        )
        subject.call
      end

      it 'will changed state to canceled' do
        expect(payment_info.canceled?).to be true
      end

      it 'last notification will has decode info' do
        expect(last_notification.information).to eq decode_data
      end

      it 'last notification is notify_type: canceled ' do
        expect(last_notification.canceled?).to be true
      end

      it 'last notification is reference: cancel_notify' do
        expect(last_notification.reference).to eq 'cancel_notify'
      end
    end
  end
end
