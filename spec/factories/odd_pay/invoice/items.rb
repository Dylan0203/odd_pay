# == Schema Information
#
# Table name: odd_pay_invoice_items
#
#  id             :bigint           not null, primary key
#  invoice_id     :bigint
#  buyable_type   :string
#  buyable_id     :bigint
#  price_cents    :integer          default(0), not null
#  price_currency :string           default("USD"), not null
#  quantity       :integer          default(1)
#  name           :string
#  description    :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
FactoryBot.define do
  factory :invoice_item, class: 'OddPay::Invoice::Item' do
  end
end
