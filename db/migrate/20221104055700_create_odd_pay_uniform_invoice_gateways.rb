class CreateOddPayUniformInvoiceGateways < ActiveRecord::Migration[6.1]
  def change
    create_table :odd_pay_uniform_invoice_gateways do |t|
      t.string :name
      t.string :gateway_provider
      t.boolean :is_default, default: false
      t.boolean :is_enabled, default: false
      t.jsonb :gateway_info, default: {}
      t.jsonb :historical_gateway_info, default: []

      t.timestamps
    end
  end
end
