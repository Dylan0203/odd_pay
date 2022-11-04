# == Schema Information
#
# Table name: odd_pay_invoices
#
#  id                :bigint           not null, primary key
#  buyer_type        :string
#  buyer_id          :bigint
#  payable_type      :string
#  payable_id        :bigint
#  billing_email     :string
#  billing_phone     :string
#  billing_address   :string
#  title             :string
#  description       :text
#  note              :text
#  invoice_type      :integer          default(0)
#  subscription_info :jsonb
#  aasm_state        :string
#  item_list         :jsonb
#  amount_cents      :integer          default(0), not null
#  amount_currency   :string           default("USD"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
module OddPay
  class Invoice < ApplicationRecord
    belongs_to :buyer, polymorphic: true, touch: true, optional: true
    belongs_to :buyable, polymorphic: true, touch: true, optional: true
    has_many :payment_infos
    has_many :notifications, through: :payment_infos
    has_many :payments, through: :payment_infos
  end
end
