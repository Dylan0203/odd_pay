class RenamePaymentColumns < ActiveRecord::Migration[6.1]
  def change
    rename_column :odd_pay_payments, :started_at, :paid_at
    rename_column :odd_pay_payments, :ended_at, :expired_at
  end
end
