OddPay::Engine.routes.draw do
  resources :payment_infos, only: %i() do
    resource :notify, only: %i(create), controller: 'payment_infos/notify'
    resource :thanks_for_purchase, only: %i(create show), controller: 'payment_infos/thanks_for_purchase'
    resource :async_payment, only: %i(create show), controller: 'payment_infos/async_payment'
  end
end
