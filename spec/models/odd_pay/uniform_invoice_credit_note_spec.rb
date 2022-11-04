# == Schema Information
#
# Table name: odd_pay_uniform_invoice_credit_notes
#
#  id                     :bigint           not null, primary key
#  uniform_invoice_id     :bigint
#  number                 :string
#  invoice_number         :string
#  create_time            :datetime
#  remain_amount_cents    :integer          default(0), not null
#  remain_amount_currency :string           default("USD"), not null
#  raw_data               :jsonb
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
require 'rails_helper'

module OddPay
  RSpec.describe UniformInvoiceCreditNote, type: :model do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end
