class AddPaidAtOnInvoice < ActiveRecord::Migration[7.0]
  def change
    add_column :odd_pay_invoices, :paid_at, :datetime
    add_column :odd_pay_invoices, :expired_at, :datetime
  end
end
