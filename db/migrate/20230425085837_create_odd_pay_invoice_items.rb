class CreateOddPayInvoiceItems < ActiveRecord::Migration[6.1]
  def change
    remove_column :odd_pay_invoices, :payable_id, :bigint
    remove_column :odd_pay_invoices, :payable_type, :string

    create_table :odd_pay_invoice_items do |t|
      t.references :invoice, foreign_key: { to_table: 'odd_pay_invoices' }
      t.references :buyable, polymorphic: true
      t.monetize :price, default: 0
      t.integer :quantity, default: 1
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
