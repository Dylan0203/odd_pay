require 'rails_helper'

module OddPay
  RSpec.describe OddPay::NewebPay::PaymentInfoCanceler, type: :service do
    subject { OddPay::NewebPay::PaymentInfoCanceler.new(payment_info) }

    let(:payment_info) { create :payment_info }
    let(:invoice) { payment_info.invoice }
    let(:encode_response) do
      {
        "period" => "da6a5feb86df19d67c07734edf377d573a96453e1b8d4c686b228919eb2a65ac8c2beb088f5faa39cde2f298e7433eb9c9c685b1f0c9b715b7df4517a1e7902856b8d6f9d0557f4a0e2dd587ce0b33c0a41ef2e3bcdcb4543a3701cfd20f1c16675507d6ca5be7ecd8ebe373a82c09da2fd3253085c0c4c5936bded9951d17fe6e6f6e30392c01a135bd61b5749a98a99afa2a43b78d1173b6743125eecfd61b403742f064370b616da42671a2afdebdd647b7536b0d6e79e510b3fb15d572d940263767c9a64dfcd27d36c7ac1417d2faf202acb3d1b606f8e96bc66b9daf2f92cfbe5f447d236250c78f51c1646719a74981236d3520932bca7e530c495881"
      }
    end
    let(:decode_data) do
      {
        "card_no" => "",
        "message" => "該定期定額委託單終止成功",
        "is_valid" => true,
        "original_info" => {
          "Status" => "SUCCESS",
          "Message" => "該定期定額委託單終止成功",
          "Result[PeriodNo]" => "P230210112918QYydb4",
          "Result[AlterType]" => "terminate",
          "Result[MerOrderNo]" => "23_22_RPUHO1"
        },
        "response_type" => "canceled"
      }
    end

    describe '#call' do
      let!(:paid_notification) { create :notification, payment_info: payment_info, information: { "original_info": { "Result[PeriodNo]": 123 } }, notify_type: :paid }
      let(:last_notification) { payment_info.notifications.last }

      before do
        allow_any_instance_of(Spgateway::Client).to receive(:change_subscription_status).and_return(encode_response)
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

      it 'invoice will be canceled' do
        expect(invoice.canceled?).to be true
      end
    end
  end
end

# {
#   "period" => "da6a5feb86df19d67c07734edf377d573a96453e1b8d4c686b228919eb2a65ac8c2beb088f5faa39cde2f298e7433eb9c9c685b1f0c9b715b7df4517a1e7902856b8d6f9d0557f4a0e2dd587ce0b33c0a41ef2e3bcdcb4543a3701cfd20f1c16675507d6ca5be7ecd8ebe373a82c09da2fd3253085c0c4c5936bded9951d17fe6e6f6e30392c01a135bd61b5749a98a99afa2a43b78d1173b6743125eecfd61b403742f064370b616da42671a2afdebdd647b7536b0d6e79e510b3fb15d572d940263767c9a64dfcd27d36c7ac1417d2faf202acb3d1b606f8e96bc66b9daf2f92cfbe5f447d236250c78f51c1646719a74981236d3520932bca7e530c495881"
# }

# {
#   "card_no" => "",
#   "message" => "該定期定額委託單終止成功",
#   "is_valid" => true,
#   "original_info" => {
#     "Status" => "SUCCESS",
#     "Message" => "該定期定額委託單終止成功",
#     "Result[PeriodNo]" => "P230210112918QYydb4",
#     "Result[AlterType]" => "terminate",
#     "Result[MerOrderNo]" => "23_22_RPUHO1"
#   },
#   "response_type" => "canceled"
# }
