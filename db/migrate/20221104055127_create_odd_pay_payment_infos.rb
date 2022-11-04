class CreateOddPayPaymentInfos < ActiveRecord::Migration[6.1]
  def change
    create_table :odd_pay_payment_infos do |t|
      t.references :invoice, foreign_key: { to_table: 'odd_pay_invoices' }
      t.references :payment_method, foreign_key: { to_table: 'odd_pay_payment_methods' }
      t.string :merchant_order_number
      t.string :aasm_state
      t.monetize :amount, default: 0
      t.jsonb :gateway_info, default: {}

      t.timestamps
    end
  end
end
