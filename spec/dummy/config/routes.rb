Rails.application.routes.draw do
  mount OddPay::Engine => "/odd_pay"

  root 'app#index'
end
