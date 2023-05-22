# == Schema Information
#
# Table name: odd_pay_invoices
#
#  id                :bigint           not null, primary key
#  buyer_type        :string
#  buyer_id          :bigint
#  email             :string
#  contact_phone     :string
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
#  name              :string
#  company_name      :string
#  company_ein       :string
#  address           :jsonb
#  number            :string
#
module OddPay
  class Invoice < ApplicationRecord
    include AASM

    belongs_to :buyer, polymorphic: true, touch: true, optional: true
    has_many :items, class_name: 'OddPay::Invoice::Item'
    has_many :payment_infos
    has_many :notifications, through: :payment_infos
    has_many :payments, through: :payment_infos

    enum invoice_type: {
      normal: 0,
      subscription: 1
    }

    monetize :amount_cents

    validate { OddPay::Invoice::DataValidator.new(self).validate }

    after_create :ensure_invoice_number

    aasm do
      state :checkout, initial: true
      state :confirmed
      state :paid
      state :overdue
      state :canceled

      event :back_to_checkout do
        transitions from: %i(confirmed), to: :checkout
      end

      event :confirm do
        transitions from: %i(checkout), to: :confirmed
      end

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

    private

    def ensure_invoice_number
      update!(number: generate_invoice_number)
    end

    def generate_invoice_number
      Time.current.strftime(
        "#{invoice_type[0].capitalize}%y#{rand(9)}%m#{rand(9)}%d#{rand(9)}%H#{rand(9)}%M%S"
      )
    end
  end
end
