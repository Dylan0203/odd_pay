require 'rails_helper'

module OddPay
  RSpec.describe NewebPay::MerchantOrderNumberGenerator, type: :service do
    subject { NewebPay::MerchantOrderNumberGenerator.call(payment_info) }

    let(:payment_info) { create(:payment_info) }

    describe '.call' do
      it 'will generate merchant_order_number for NewebPay' do
        info = subject.split('_')
        invoice_id = info[0].to_i(36)
        payment_info_id = info[1].to_i(36)

        expect(invoice_id).to eq payment_info.invoice.id
        expect(payment_info_id).to eq payment_info.id
      end
    end
  end
end
