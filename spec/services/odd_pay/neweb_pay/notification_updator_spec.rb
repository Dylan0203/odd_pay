require 'rails_helper'

module OddPay
  RSpec.describe NewebPay::NotificationUpdater, type: :service do
    subject { NewebPay::NotificationUpdater.new(notification) }

    let(:cc_raw_data) do
      {
        "Status" => "SUCCESS",
        "Version" => "2.0",
        "TradeSha" => "04D6C815D8F21F075CB2AE133238DFD515F381F97CDBF7C664AE201D28B27676",
        "TradeInfo" => "6e0cd0eff10334d270ff9aac84a43ea89bff0bbdbafe266f4629c0fe0ba278b39d2bcf4b8729c1edaf3811ebd964693600bdf2e3cf5a15802b272f6f9d8edaecbb9e12571bb1bc1b1f7ee332618227eba747d236d1db81dee7438b8a5e25d7aaddc248aa6cc67f4737189cb08c55de4b8d6d9b6b371d4818101f79c3e8273c95039128cd7645efae423cb9bc61bca05d4d37beebcf81dac32293e75ac581df7ad7e6d252fcdd6dc49e47299b1fa3aa0f2306cb378e65ab34f65ae72f2ae6a9773cadda81597701a7d0f2c9f6bfd343289e35355c5bd4e53f60075b75069850d4a89de36fe92353655e9c94f2b7b6800db11945eb9804e679f6fa5a667b34bab5e3e58223837a352ad7468b08df246e6c70446b9e6635c184295570fafd5e05400c26ec2ed85d1c92b110d3ea1fca9eeb01f665c6fb112d4f36f6ae15c08a54e3b115756306bf446d627d38427a37df73165f33d053bfa6360e0c2ab5b041da00b638b0a79ba1249b3f5ddc34feaa9a39b916cf91cc371282e2a32f265f6833b96628a182c16ae64130212a7507cdb32503b659ea6216da55ca5964bb0336fe083b45ea18d0faf95169d4068a766cd938ed2136d1bbdefac6abb9e2d649776579f9707292e55300586df65562fcb4277387bcdefc0f8f03ffe00456731b64ec1d",
        "MerchantID" => "MS344441353"
      }
    end

    let(:period_raw_data) do
      {
        "Period" => "6e0cd0eff10334d270ff9aac84a43ea89bff0bbdbafe266f4629c0fe0ba278b365ccc9eac841751b875b5529476a69209b6b790679dca5bf62011e6271fcb114d1ee88a4700d12dba03c313b4930221b79d3ecf88ec87de67db18bae894673de51fd8c43842017631b1fbff2d46c06e3b42b56f255472b5934b15d2b98b08c5c88a9d45e5dd8ad0ed9ae4718dce518c698b325dce5f976dfc5c91c4f9243cfb90e51cc5e258bce0a829b11487f343fd75908af70c42f25c7927f47a733ad3d7e684dfa2bd6fca9de756b38b45da6c1bc4a54a55eb8335391e1c6ad5070eff83a4b9a3ee64b79a88640fc81e4cf35fb5c489ca0d0b8008d2222bdce15b977ff302186fd5c4dba61849cad4e4e0dcd416e409d079edf232cf1af6e0028f589b4c9833efa918c1c68c8e38c2cbc0cc4fac51fcff4e56c7a12c6945418ea8d56b0da86b29c3df889f7bda235d998f49a6721faf72615e5a360febae967ae58fe0467eaea06e8af6709ad1976d223dff72f8e1a6a70354de9b7300f6a79f48183c1cebcd35a86cf42d8b6ecb4deead3e8520a70980975ac9217c51fa03875c6597dca86b50b42fafee9191b57d6d26fa2d5dde7921c1d81a5fddcbfe80369469a35b892fb88cf9a1ade8b07b76a6b375180a8a6e143a58d22dbf26f8aeb30b8b897e5"
      }
    end
    let(:notification) { create :notification, reference: :payment_notify, raw_data: cc_raw_data }
    let(:payment_info) { notification.payment_info }

    describe '#update' do
      it 'will update data' do
        expect(notification.notify_type.to_sym).to be :init
        expect(notification.information.blank?).to be true

        subject.update

        expect(notification.notify_type.to_sym).not_to be :init
        expect(notification.information.present?).to be true
      end
    end

    describe 'When payment type is normal' do
      before do
        payment_info.invoice.update! invoice_type: :normal
        payment_info.payment_method.update! payment_type: :credit_card
        payment_info.save!
      end

      Composables::InformationComposer::FETCH_DATA_METHODS.each do |key|
        it "#{key} will get value" do
          expect(subject.send(key)).to be_truthy
        end
      end

      describe '#response_type' do
        def mark_api_succeed_false
          allow_any_instance_of(NewebPay::NotificationUpdater).to receive(:api_succeed).and_return false
        end

        context 'when notification.reference is :payment_notify' do
          context 'and api_succeed is true' do
            it 'will return :paid' do
              expect(subject.response_type).to be :paid
            end

            context 'and api_succeed is false' do
              before { mark_api_succeed_false }

              it 'will return :failed' do
                expect(subject.response_type).to be :failed
              end
            end
          end
        end

        context 'when notification.reference is :async_payment_notify' do
          before { notification.update! reference: :async_payment_notify }

          context 'and api_succeed is true' do
            it 'will return :async_payment_info' do
              expect(subject.response_type).to be :async_payment_info
            end

            context 'and api_succeed is false' do
              before { mark_api_succeed_false }

              it 'will return :init' do
                expect(subject.response_type).to be :init
              end
            end
          end
        end

        context 'when notification.reference is :cancel_notify' do
          before { notification.update! reference: :cancel_notify }

          context 'and api_succeed is true' do
            it 'will return :canceled' do
              expect(subject.response_type).to be :canceled
            end

            context 'and api_succeed is false' do
              before { mark_api_succeed_false }

              it 'will return :init' do
                expect(subject.response_type).to be :init
              end
            end
          end
        end
      end
    end

    describe 'When payment type is subcription' do
      before do
        notification.update! raw_data: period_raw_data
        payment_info.payment_method.update! payment_type: :subscription
        payment_info.save!
      end

      Composables::InformationComposer::FETCH_DATA_METHODS.each do |key|
        it "#{key} will get value" do
          expect(subject.send(key)).to be_truthy
        end
      end
    end
  end
end
