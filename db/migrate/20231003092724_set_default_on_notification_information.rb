class SetDefaultOnNotificationInformation < ActiveRecord::Migration[6.1]
  def up
    change_column :odd_pay_notifications, :information, :jsonb, default: {}
  end

  def down
    change_column :odd_pay_notifications, :information, :jsonb
  end
end
