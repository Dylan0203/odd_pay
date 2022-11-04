# == Schema Information
#
# Table name: odd_pay_notifications
#
#  id              :bigint           not null, primary key
#  payment_info_id :bigint
#  raw_data        :jsonb
#  notify_type     :integer          default(0)
#  information     :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
module OddPay
  class Notification < ApplicationRecord
  end
end
