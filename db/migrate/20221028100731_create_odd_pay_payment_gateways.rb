class CreateOddPayPaymentGateways < ActiveRecord::Migration[6.1]
  def change
    create_table :odd_pay_payment_gateways do |t|
      t.string :name
      t.string :gateway_provider
      t.jsonb :gateway_info, default: {}
      t.jsonb :historical_gateway_info, default: []

      t.timestamps
    end
  end
end
