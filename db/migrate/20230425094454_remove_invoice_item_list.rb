class RemoveInvoiceItemList < ActiveRecord::Migration[6.1]
  def change
    remove_column :odd_pay_invoices, :item_list, :jsonb
  end
end
