class AddStateColumnsOnInvoice < ActiveRecord::Migration[6.1]
  def change
    rename_column :odd_pay_invoices, :aasm_state, :invoice_state
    add_column :odd_pay_invoices, :payment_state, :string
    add_column :odd_pay_invoices, :shipment_state, :string
  end
end
