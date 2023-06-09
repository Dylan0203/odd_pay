class CreateOddPayPaymentMethods < ActiveRecord::Migration[6.1]
  def change
    create_table :odd_pay_payment_methods do |t|
      t.references :payment_gateway, foreign_key: { to_table: 'odd_pay_payment_gateways' }
      t.string :name
      t.text :description
      t.string :payment_type
      t.boolean :enabled, default: false

      t.timestamps
    end
  end
end
