class CreateOddPayNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :odd_pay_notifications do |t|
      t.references :payment_info, foreign_key: { to_table: 'odd_pay_payment_infos' }
      t.jsonb :raw_data
      t.integer :notify_type, default: 0
      t.jsonb :information

      t.timestamps
    end
  end
end
