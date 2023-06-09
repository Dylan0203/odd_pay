require 'rails_helper'

module OddPay
  RSpec.describe OddPay::NewebPay::NotificationUpdater, type: :service do
    subject { OddPay::NewebPay::NotificationUpdater.new(notification) }

    let(:cc_raw_data) do
      {
        "Status" => "SUCCESS",
        "MerchantID" => "MS344441353",
        "Version" => "2.0",
        "TradeInfo" => "da6a5feb86df19d67c07734edf377d57af844ce547b825d09e22e5afacf4e6ca8c8184406be843486045b1e25de3f88fc165921f92cf5769fa4d48e9f00f73d94650dc1060028f23103bd301ed1f295433f8f0b0ddecc0f798c423a68e6d0937b46414102c7e881d07d3a0adaaa39d909904bdeb9d6d964522ebe183a9c665e6db869514a95825f7d5703beb019417eecb7c91cff1be080d28971e9a7d001e7aa622d8857ac4371c848da0142e52d590ef86a44a520ad3291f73319f55e666cbf28abec3391bf9f3135f49d4e66a38343dda75554aeb551c9466acf5145645cef6a7408137c674f082db06052f6450861c9aa721cadc8aba7d4b917ed4840a42b98ae7b314245f836987a2d226a2c14252387e1aa235fb0118a8fadadaae94f69469f3fe63164824d0b2ce95c330f0452e92bf16c89d419b84ba52036926e87404938cc83f640817f9d7474ebd5fae73c1859b9389585b85e54f45c893dd22682df119846e0a6c9d48e33c36e843047c4f05698bda7c9129111e917fdacd963f0ff2a00f15a1cbfdfbb8ddc2f3478d1bb70371abd447835ef760ee12557b8710c571b31e82cf7a0b3f562fc16fa253ef653d291b96487e7389e7cde09655d177",
        "TradeSha" => "1D2DF79F1903BE665E7294835B0DE413FC1FAEC269510061F16B85930F73859A"
      }
    end

    let(:period_raw_data) do
      {
        "Period" => "da6a5feb86df19d67c07734edf377d57c4594fae3c8282c06a832c72b467d280e7eae4279eb2aee39ec5da9065a7ef415f365f21a3127669e669094cbec75df3b4cb11e8f09fb4253ae6ca08b8ce34bde8e549ef3114d6afa677e4daa9c65634a67c4ec26aa406b830691014901299a2108d633c913b9bb51d0bf7507dce3dbeb956a704e251ea8e9c052904e395362077e5b82fddf697fc2729e57d31f29e39f6a97871944520c4c45768537c0a55c847f24298d4548f7605debd7f78c375e82b1e83c51ba5a74dab5eb3f07b29663d6f73bc007d0f27a16cad68fb5c9b5c7bbeb5b0136913b3363f701c17120c52af7bc62c2bdf845bc33f28036f890002d3d2db056eb447bfcb65ccaeb212adba811619f72fc55b7a3c920094db3f0f3a57fb4112436823aac7d7db4bda20e6064fb54e277a4d6c390922dfa820c1d178eb0add298fc6009360ba1ad2acb4333effdc14f62da31dc7f3e5ecd479e39ad477ad0a676db651ae3dfcd11ac51584dfe4df1c3467d3ce0c3d3e830547674297624dc856402e672a30e630ef3dae896ecabee89aa7472fe01ed56b485c4fcfc8b90f35082995551bd6ea42465c36052500311134958c1996fc8c32ef352038c276e0616ba9d824b21aae53740f1a01ec4e67e15ef613fc3a1672f9300b700e2ccd915a26981d976d7cb6850c9a4f46afa8ed4c57c7bd587f02aa55fcbf704a30bb92d25b3b1a4cbd445ccad4482fa5d8fcb7fc69f161cfbbb9ff784b013458a10a140cdaebc498eaf5507ab1a78378607cad6a676eb4016e493b494fe901ea0a0e011adf6e9c1c588ae4bdf7cc98a8fe05e325292eb147e31ef09fd65bb6fe1bf93695e8c89867e8f0e529f2b0de42766767251260b861d9ee93c9e41166e02b55d194500914cf25eda878f6553dd414ecc621b5de74c92943e9da58851134998e"
      }
    end
    let(:notification) { create :notification, reference: :payment_notify, raw_data: cc_raw_data }
    let(:payment_info) { notification.payment_info }

    describe '#update' do
      it 'will update data' do
        expect(notification.notify_type.to_sym).to be :init
        expect(notification.information).to be_nil

        subject.update

        expect(notification.notify_type.to_sym).not_to be :init
        expect(notification.information).not_to be_nil
      end
    end

    describe 'When payment type is normal' do
      before do
        payment_info.invoice.update! invoice_type: :normal
        payment_info.payment_method.update! payment_type: :credit_card
        payment_info.save!
      end

      OddPay::Composables::InformationComposer::FETCH_DATA_METHODS.each do |key|
        it "#{key} will get value" do
          expect(subject.send(key)).to be_truthy
        end
      end

      describe '#response_type' do
        def mark_api_succeed_false
          allow_any_instance_of(OddPay::NewebPay::NotificationUpdater).to receive(:api_succeed).and_return false
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

      OddPay::Composables::InformationComposer::FETCH_DATA_METHODS.each do |key|
        it "#{key} will get value" do
          expect(subject.send(key)).to be_truthy
        end
      end
    end
  end
end
