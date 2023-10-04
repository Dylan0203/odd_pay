class AddUniquenessConstraintOnPaymentPaidAt < ActiveRecord::Migration[6.1]
  def change
    add_index :odd_pay_payments, [:paid_at, :payment_info_id], unique: true
    add_index :odd_pay_refunds, [:refunded_at, :payment_info_id], unique: true
  end
end
