class CreateOddPayRefunds < ActiveRecord::Migration[6.1]
  def change
    create_table :odd_pay_refunds do |t|
      t.references :payment_info, foreign_key: { to_table: 'odd_pay_payment_infos' }
      t.monetize :amount, default: 0
      t.string :aasm_state
      t.datetime :refunded_at
      t.string :bank_code
      t.string :account
      t.string :recipient

      t.timestamps
    end
  end
end
