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
#  invoice_type      :integer          default("normal")
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
    include AASM

    belongs_to :buyer, polymorphic: true, touch: true, optional: true
    belongs_to :buyable, polymorphic: true, touch: true, optional: true
    has_many :payment_infos
    has_many :notifications, through: :payment_infos
    has_many :payments, through: :payment_infos

    enum invoice_type: {
      normal: 0,
      subscription: 1
    }

    monetize :amount_cents

    validate { OddPay::Invoice::DataValidator.new(self).validate }

    aasm do
      state :checkout, initial: true
      state :paid
      state :overdue
      state :canceled

      event :pay do
        transitions from: %i(checkout paid overdue), to: :paid
      end

      event :expire do
        transitions from: %i(paid), to: :overdue
      end

      event :cancel do
        transitions from: %i(processing paid), to: :canceled
      end
    end

    def normalized_item_list
      item_list.map do |info|
        {
          name: info['name'],
          quantity: info['quantity'].to_i,
          unit_price: info['unit_price'].to_i
        }
      end
    end

    def period_type
      subscription_info['period_type'].try(:to_sym)
    end

    def period_point
      subscription_info['period_point'].to_i
    end

    def period_times
      subscription_info['period_times'].to_i
    end

    def grace_period_in_days
      subscription_info['grace_period_in_days'].to_i.days
    end

    def available_payment_methods
      OddPay::PaymentMethod.where(
        enabled: true,
        payment_type: OddPay::PaymentGatewayService::AVAILABLE_PAYMENT_TYPE_MAP[invoice_type.to_sym]
      )
    end
  end
end
