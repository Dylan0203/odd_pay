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
#
FactoryBot.define do
  factory :invoice, class: 'OddPay::Invoice' do
    email { 'email' }
    contact_phone { 'contact_phone' }
    address do
      { street: 'street' }
    end
    invoice_type { :subscription }

    subscription_info do
      {
        period_type: 'days',
        period_point: 2,
        period_times: 99,
        grace_period_in_days: 2
      }
    end
  end
end
