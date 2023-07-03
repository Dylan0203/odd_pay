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
module OddPay
  class Notification < ApplicationRecord
    belongs_to :payment_info
    has_one :invoice, through: :payment_info

    enum notify_type: {
      init: 0,
      paid: 1,
      failed: 2,
      canceled: 3,
      async_payment_info: 4
    }

    validate { OddPay::Notification::DataValidator.new(self).validate }

    scope :has_notify_type, -> { where.not(notify_type: :init) }

    def is_waiting_async_payment_info
      async_payment_info? && information['expired_at'].in_time_zone > Time.current
    end
  end
end
