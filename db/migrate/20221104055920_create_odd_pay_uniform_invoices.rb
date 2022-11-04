class CreateOddPayUniformInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :odd_pay_uniform_invoices do |t|
      t.references :payment, foreign_key: { to_table: 'odd_pay_payments' }
      t.references :uniform_invoice_gateway, foreign_key: { to_table: 'odd_pay_uniform_invoice_gateways' }
      t.string :invoice_trans_no
      t.monetize :total_amount, default: 0
      t.string :invoice_number
      t.string :random_number
      t.string :bar_code
      t.string :qr_code_l
      t.string :qr_code_r
      t.datetime :create_time
      t.string :status_message
      t.string :aasm_state
      t.text :comment
      t.jsonb :raw_data

      t.timestamps
    end
  end
end
