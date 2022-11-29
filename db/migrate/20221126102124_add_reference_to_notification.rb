class AddReferenceToNotification < ActiveRecord::Migration[6.1]
  def change
    add_column :odd_pay_notifications, :reference, :string
  end
end
