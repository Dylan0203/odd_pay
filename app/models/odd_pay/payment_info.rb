# == Schema Information
#
# Table name: odd_pay_payment_infos
#
#  id                    :bigint           not null, primary key
#  invoice_id            :bigint
#  payment_method_id     :bigint
#  merchant_order_number :string
#  aasm_state            :string
#  amount_cents          :integer          default(0), not null
#  amount_currency       :string           default("USD"), not null
#  gateway_info          :jsonb
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
module OddPay
  class PaymentInfo < ApplicationRecord
    include AASM
    include OddPay::Concerns::IdHashable

    belongs_to :invoice, touch: true
    belongs_to :payment_method
    has_many :notifications
    has_many :payments

    scope :expired, lambda {
      paid.
        where(
          '? >= (SELECT MAX(ended_at) FROM odd_pay_payments WHERE payment_info_id = odd_pay_payment_infos.id)',
          Time.current
        )
    }

    monetize :amount_cents

    validate { OddPay::PaymentInfo::DataValidator.new(self).validate }

    aasm do
      state :checkout, initial: true
      state :processing
      state :waiting_async_payment
      state :paid
      state :overdue
      state :failed
      state :canceled
      state :void

      event :process do
        transitions from: %i(checkout), to: :processing
      end

      event :wait do
        transitions from: %i(processing waiting_async_payment), to: :waiting_async_payment
      end

      event :pay do
        transitions from: %i(processing paid overdue), to: :paid
      end

      event :expire do
        transitions from: %i(paid), to: :overdue
      end

      event :fail do
        transitions from: %i(processing), to: :failed
        after { create_new_payment_info }
      end

      event :cancel do
        transitions from: %i(checkout processing paid), to: :canceled
      end

      event :ignore do
        transitions from: %i(processing), to: :void
      end
    end

    def current_payment_gateway
      @current_payment_gateway ||= PaymentGateway.find(gateway_info['gateway_id'])
    end

    def payment_type
      gateway_info['payment_type'].to_sym
    end

    def generate_post_info(params = {})
      ActiveRecord::Base.transaction do
        assign_attributes(
          merchant_order_number: OddPay::PaymentGatewayService.generate_merchant_order_number(self)
        )
        process!
        ignore_processing_payment_infos
        OddPay::PaymentGatewayService.generate_post_info(self, params)
      end
    end

    private

    def create_new_payment_info
      invoice.payment_infos.create!(payment_method: payment_method)
    end

    def ignore_processing_payment_infos
      invoice.payment_infos.processing.each do |payment_info|
        payment_info.ignore! if payment_info != self
      end
    end
  end
end
