require 'odd_pay/act_as_buyer'
require 'money'

module OddPay
  class Engine < ::Rails::Engine
    isolate_namespace OddPay

    config.default_url_options = { host: 'odd-pay.odd.tw', protocol: 'https' }

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end
  end
end
