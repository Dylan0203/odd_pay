class AddExtraInfoOnInvoiceItems < ActiveRecord::Migration[7.0]
  def change
    add_column :odd_pay_invoice_items, :extra_info, :jsonb, default: {}
  end
end
