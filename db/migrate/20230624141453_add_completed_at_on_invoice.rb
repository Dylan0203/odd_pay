class AddCompletedAtOnInvoice < ActiveRecord::Migration[7.0]
  def change
    add_column :odd_pay_invoices, :completed_at, :datetime
  end
end
