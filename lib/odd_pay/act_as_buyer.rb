module OddPay::ActAsBuyer
  extend ActiveSupport::Concern

  included do
    has_many :invoices, as: :buyer, class_name: 'OddPay::Invoice'
  end
end
