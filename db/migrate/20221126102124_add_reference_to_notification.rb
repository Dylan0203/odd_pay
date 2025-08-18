class AddReferenceToNotification < ActiveRecord::Migration[7.0]
  def change
    add_column :odd_pay_notifications, :reference, :string
  end
end
