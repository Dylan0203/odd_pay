class AdjustInvoiceColumns < ActiveRecord::Migration[6.1]
  def change
    rename_column :odd_pay_invoices, :billing_email, :email
    rename_column :odd_pay_invoices, :billing_phone, :contact_phone
    add_column :odd_pay_invoices, :name, :string
    add_column :odd_pay_invoices, :company_name, :string
    add_column :odd_pay_invoices, :company_ein, :string
    add_column :odd_pay_invoices, :address, :jsonb, default: {}
    remove_column :odd_pay_invoices, :billing_address, :string
  end
end
