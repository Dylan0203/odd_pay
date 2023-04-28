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
FactoryBot.define do
  factory :invoice, class: 'OddPay::Invoice' do
    billing_email { 'billing_email' }
    billing_phone { 'billing_phone' }
    billing_address { 'billing_address' }
    invoice_type { :subscription }

    subscription_info do
      {
        period_type: 'days',
        period_point: '01',
        period_times: 99,
        grace_period_in_days: 2
      }
    end
  end
end
