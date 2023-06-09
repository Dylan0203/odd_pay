module OddPay::ActAsBuyer
  extend ActiveSupport::Concern

  included do
    has_many :odd_pay_invoices, as: :buyer, class_name: 'OddPay::Invoice'
  end
end
