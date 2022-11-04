class CreateOddPayPayments < ActiveRecord::Migration[6.1]
  def change
    create_table :odd_pay_payments do |t|
      t.references :payment_info, foreign_key: { to_table: 'odd_pay_payment_infos' }
      t.monetize :amount, default: 0
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
