class AddRefundStateOnPaymentInfo < ActiveRecord::Migration[7.0]
  def change
    add_column :odd_pay_payment_infos, :refund_state, :string
  end
end
