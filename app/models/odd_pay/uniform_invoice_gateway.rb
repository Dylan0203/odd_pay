# == Schema Information
#
# Table name: odd_pay_uniform_invoice_gateways
#
#  id                      :bigint           not null, primary key
#  name                    :string
#  gateway_provider        :string
#  is_default              :boolean          default(FALSE)
#  is_enabled              :boolean          default(FALSE)
#  gateway_info            :jsonb
#  historical_gateway_info :jsonb
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
module OddPay
  class UniformInvoiceGateway < ApplicationRecord
    has_many :uniform_invoices
  end
end
