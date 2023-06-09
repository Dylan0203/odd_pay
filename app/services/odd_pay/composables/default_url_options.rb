module OddPay
  module Composables
    module DefaultUrlOptions
      def default_url_optoins
        OddPay::Engine.config.default_url_options
      end
    end
  end
end
