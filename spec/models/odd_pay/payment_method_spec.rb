# == Schema Information
#
# Table name: odd_pay_payment_methods
#
#  id                 :bigint           not null, primary key
#  payment_gateway_id :bigint
#  name               :string
#  description        :text
#  payment_type       :string
#  enabled            :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
require 'rails_helper'

module OddPay
  RSpec.describe PaymentMethod, type: :model do
    # associations
    it { should belong_to(:payment_gateway) }
  end
end
