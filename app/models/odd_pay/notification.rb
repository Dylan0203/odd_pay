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
      async_payment_info: 4,
      collected: 5,
      deauthorized: 6,
      refunded: 7,
      current_payment_info: 8
    }

    validate { OddPay::Notification::DataValidator.new(self).validate }

    scope :has_notify_type, -> { where.not(notify_type: %i(init current_payment_info)) }

    def async_payment_info
      return unless async_payment_info?
      expired_at = information['expired_at']
      return unless expired_at.in_time_zone > Time.current

      {
        bank_code: information['bank_code'],
        code_no: information['code_no'],
        amount: information['amount'],
        expired_at: expired_at
      }
    end

    def update_info
      OddPay::PaymentGatewayService.update_notification(self)
    end

    def compose_info
      OddPay::PaymentGatewayService.parse_notification(self)
    end

    def decode_data
      OddPay::PaymentGatewayService.decode_data(self)
    end
  end
end
