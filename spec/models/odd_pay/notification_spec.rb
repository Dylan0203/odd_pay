# == Schema Information
#
# Table name: odd_pay_notifications
#
#  id              :bigint           not null, primary key
#  payment_info_id :bigint
#  raw_data        :jsonb
#  notify_type     :integer          default("init")
#  information     :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  reference       :string
#
require 'rails_helper'

module OddPay
  RSpec.describe Notification, type: :model do
    # associations
    it { should belong_to(:payment_info) }

    describe 'scopes' do
      describe 'has_notify_type' do
        let!(:notification_1) { create :notification, notify_type: :paid }
        let!(:notification_2) { create :notification, notify_type: :failed }
        let!(:notification_3) { create :notification, notify_type: :canceled }
        let!(:notification_4) { create :notification, notify_type: :async_payment_info }
        let!(:notification_5) { create :notification }

        it 'will not have notification with init state' do
          expect(Notification.has_notify_type.size).to be 4
        end
      end
    end
  end
end
