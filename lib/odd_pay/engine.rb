require 'odd_pay/act_as_buyer'
require 'money'

module OddPay
  class Engine < ::Rails::Engine
    isolate_namespace OddPay

    Money.locale_backend = :currency

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end
  end
end
