module OddPay
  module Composables
    module PaymentGatewayApiClient
      InvalidGatewaySource = Class.new(StandardError)

      def gateway_source
        raise InvalidGatewaySource, 'Please provide @gateway_source' unless @gateway_source
        @gateway_source
      end

      def payment_gateway
        @payment_gateway ||= begin
          case gateway_source
          when OddPay::PaymentGateway
            gateway_source
          when OddPay::PaymentInfo
            gateway_source.current_payment_gateway
          when OddPay::Notification
            gateway_source.payment_info.current_payment_gateway
          else
            raise InvalidGatewaySource, gateway_source
          end
        end
      end

      def gateway_provider
        @gateway_provider ||= payment_gateway.gateway_provider.to_sym
      end

      def api_client
        @api_client ||= begin
          gateway_info = payment_gateway.gateway_info.with_indifferent_access
          case gateway_provider
          when :NewebPay
            Spgateway::ClientV2.new(
              merchant_id: gateway_info[:merchant_id],
              hash_key: gateway_info[:hash_key],
              hash_iv: gateway_info[:hash_iv],
              mode: Rails.env.production? ? :production : :test
            )
          end
        end
      end
    end
  end
end
