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
#  refund_state          :string
#
module OddPay
  class PaymentInfo < ApplicationRecord
    include AASM
    include OddPay::Concerns::IdHashable

    InvalidInvoiceState = Class.new(StandardError)

    belongs_to :invoice, touch: true
    belongs_to :payment_method
    has_many :notifications, dependent: :destroy
    has_many :payments, dependent: :destroy
    has_many :refunds, dependent: :destroy

    monetize :amount_cents

    validate { OddPay::PaymentInfo::DataValidator.new(self).validate }

    aasm do
      state :checkout, initial: true
      state :processing
      state :waiting_async_payment
      state :paid
      state :canceled
      state :failed
      state :void

      event :process do
        transitions from: %i(checkout), to: :processing
      end

      event :wait do
        transitions from: %i(processing waiting_async_payment), to: :waiting_async_payment
      end

      event :pay do
        transitions from: %i(processing paid), to: :paid
      end

      event :fail do
        transitions from: %i(processing), to: :failed
      end

      # only for subscription
      event :cancel do
        transitions from: %i(paid), to: :canceled
      end

      event :ignore do
        transitions from: %i(checkout processing), to: :void
      end
    end

    aasm(:refund_state, column: :refund_state) do
      state :init, initial: true
      state :partial_refunded
      state :refunded

      event :partial_refund do
        transitions from: %i(init), to: :partial_refunded
      end

      event :refund do
        transitions from: %i(init partial_refunded), to: :refunded
      end
    end

    def current_payment_gateway
      @current_payment_gateway ||= PaymentGateway.find(gateway_info['gateway_id'])
    end

    def payment_type
      gateway_info['payment_type'].to_sym
    end

    def generate_post_info(params = {})
      raise InvalidInvoiceState, 'only completed invoice can generate post_info' unless invoice.completed?

      ActiveRecord::Base.transaction do
        assign_attributes(
          merchant_order_number: OddPay::PaymentGatewayService.generate_merchant_order_number(self)
        )
        process!
        ignore_checkout_and_processing_payment_infos
        OddPay::PaymentGatewayService.generate_post_info(self, params)
      end
    end

    def update_info
      OddPay::PaymentGatewayService.update_payment_info(self)
    end

    private

    def ignore_checkout_and_processing_payment_infos
      invoice.payment_infos.where(aasm_state: [:checkout, :processing]).each do |payment_info|
        payment_info.ignore! if payment_info != self
      end
    end
  end
end
