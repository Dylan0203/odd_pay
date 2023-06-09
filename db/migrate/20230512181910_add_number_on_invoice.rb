class AddNumberOnInvoice < ActiveRecord::Migration[6.1]
  def change
    add_column :odd_pay_invoices, :number, :string
  end
end
