class AddNumberOnInvoice < ActiveRecord::Migration[7.0]
  def change
    add_column :odd_pay_invoices, :number, :string
  end
end
