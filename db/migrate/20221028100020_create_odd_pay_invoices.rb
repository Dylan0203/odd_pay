class CreateOddPayInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :odd_pay_invoices do |t|
      t.references :buyer, polymorphic: true
      t.references :payable, polymorphic: true
      t.string :billing_email
      t.string :billing_phone
      t.string :billing_address
      t.string :title
      t.text :description
      t.text :note
      t.integer :invoice_type, default: 0
      t.jsonb :subscription_info, default: {}
      t.string :aasm_state
      t.jsonb :item_list, default: []
      t.monetize :amount, default: 0

      t.timestamps
    end
  end
end
