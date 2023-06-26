class AddCompletedAtOnInvoice < ActiveRecord::Migration[6.1]
  def change
    add_column :odd_pay_invoices, :completed_at, :datetime
  end
end
