class AddExtraInfoOnInvoiceItems < ActiveRecord::Migration[6.1]
  def change
    add_column :odd_pay_invoice_items, :extra_info, :jsonb, default: {}
  end
end
