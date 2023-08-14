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
#  invoice_state     :string
#  amount_cents      :integer          default(0), not null
#  amount_currency   :string           default("USD"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  name              :string
#  company_name      :string
#  company_ein       :string
#  address           :jsonb
#  number            :string
#  completed_at      :datetime
#  payment_state     :string
#  shipment_state    :string
#
module OddPay
  class Invoice < ApplicationRecord
    include AASM

    belongs_to :buyer, polymorphic: true, touch: true, optional: true
    has_many :items, class_name: 'OddPay::Invoice::Item'
    has_many :payment_infos
    has_many :notifications, through: :payment_infos
    has_many :payments, through: :payment_infos

    scope :incomplete, -> { where(completed_at: nil) }
    scope :completed_already, -> { where.not(completed_at: nil) }

    enum invoice_type: {
      normal: 0,
      subscription: 1
    }

    monetize :amount_cents

    validate { OddPay::Invoice::DataValidator.new(self).validate }

    after_create :ensure_invoice_number

    aasm(:invoice_state, column: :invoice_state) do
      state :cart, initial: true
      state :confirmed
      state :completed
      state :canceled

      event :back_to_cart do
        transitions from: %i(cart confirmed), to: :cart
      end

      event :confirm do
        transitions from: %i(cart confirmed), to: :confirmed
      end

      event :complete do
        transitions from: %i(confirmed), to: :completed
        after do
          update! completed_at: Time.current
        end
      end

      event :cancel do
        transitions from: %i(completed), to: :canceled
      end
    end

    aasm(:payment_state, column: :payment_state) do
      state :checkout, initial: true
      state :balance_due
      state :credit_owed
      state :paid
      state :overdue
      state :void

      event :balance_owe do
        transitions from: %i(checkout), to: :balance_due
      end

      event :credit_owe do
        transitions from: %i(checkout paid balance_due), to: :credit_owed
      end

      event :pay do
        transitions from: %i(checkout balance_due paid overdue), to: :paid, guard: :payable?
      end

      event :expire do
        transitions from: %i(paid), to: :overdue
      end
    end

    aasm(:shipment_state, column: :shipment_state) do
      state :shipment_pending, initial: true
      state :shipment_ready
      state :shipped
      state :partial_shipped

      event :ship do
        transitions from: %i(shipment_ready partial_shipped), to: :shipped
      end

      event :partial_ship do
        transitions from: %i(shipment_ready), to: :partial_shipped
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
        # enabled: true,
        payment_type: OddPay::PaymentGatewayService::AVAILABLE_PAYMENT_TYPE_MAP[invoice_type.to_sym]
      )
    end

    def unpaid_amount
      amount - Money.new(payment_infos.paid.sum(:amount_cents))
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

    def payable?
      case invoice_type
      when 'subscription'
        true
      when 'normal'
        !paid?
      end
    end
  end
end
