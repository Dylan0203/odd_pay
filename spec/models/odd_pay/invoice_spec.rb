# == Schema Information
#
# Table name: odd_pay_invoices
#
#  id                :bigint           not null, primary key
#  buyer_type        :string
#  buyer_id          :bigint
#  billing_email     :string
#  billing_phone     :string
#  billing_address   :string
#  title             :string
#  description       :text
#  note              :text
#  invoice_type      :integer          default("normal")
#  subscription_info :jsonb
#  aasm_state        :string
#  amount_cents      :integer          default(0), not null
#  amount_currency   :string           default("USD"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require 'rails_helper'

module OddPay
  RSpec.describe Invoice, type: :model do
    # associations
    it { should have_many(:items) }
    it { should have_many(:payment_infos) }
    it { should have_many(:notifications).through(:payment_infos) }
    it { should have_many(:payments).through(:payment_infos) }
  end
end
