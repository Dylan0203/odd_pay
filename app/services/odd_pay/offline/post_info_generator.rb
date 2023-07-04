module OddPay
  module Offline
    class PostInfoGenerator
      include OddPay::Composables::DefaultUrlOptions

      attr_reader :payment_info, :params

      def initialize(payment_info, params)
        @payment_info = payment_info
        @params = params
      end

      def self.call(payment_info, params)
        new(payment_info, params).call
      end

      def call
        {
          post_url: async_payment_url,
          post_params: {}
        }
      end

      private

      def async_payment_url
        params[:async_payment_url] ||
          Engine.routes.url_helpers.payment_info_async_payment_url({ payment_info_id: payment_info.hashid }.merge(default_url_optoins))
      end
    end
  end
end
