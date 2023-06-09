class CreateOddPayUniformInvoiceCreditNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :odd_pay_uniform_invoice_credit_notes do |t|
      t.references :uniform_invoice,
                    foreign_key: { to_table: 'odd_pay_uniform_invoices' },
                    index: { name: 'index_op_uniform_invoice_credit_notes_on_uniform_invoice_id' }
      t.string :number
      t.string :invoice_number
      t.datetime :create_time
      t.monetize :remain_amount, default: 0
      t.jsonb :raw_data

      t.timestamps
    end
  end
end
