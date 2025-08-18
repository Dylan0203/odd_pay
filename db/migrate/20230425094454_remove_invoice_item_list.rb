class RemoveInvoiceItemList < ActiveRecord::Migration[7.0]
  def change
    remove_column :odd_pay_invoices, :item_list, :jsonb
  end
end
