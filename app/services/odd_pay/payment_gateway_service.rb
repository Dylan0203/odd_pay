module OddPay
  class PaymentGatewayService
    include OddPay::Composables::ApiClient

    AVAILABLE_GATEWAYS = %i(NewebPay).freeze
    PAYMENT_METHOD_MAP = {
      NewebPay: %i(
        subscription
        credit_card
        vacc
        webatm
        credit_card_inst_3
        credit_card_inst_6
        credit_card_inst_12
        credit_card_inst_18
        credit_card_inst_24
        credit_card_inst_30
        android_pay
        samsung_pay
        union_pay
        cvs
        barcode
        cvscom
      )
    }.freeze

    def initialize(gateway_source)
      @gateway_source = gateway_source
    end

    def self.generate_merchant_order_number(payment_info)
      new(payment_info).generate_merchant_order_number
    end

    def self.generate_post_info(payment_info, params)
      new(payment_info).generate_post_info(params)
    end

    def self.update_notification(notification)
      new(notification).update_notification
    end

    def self.parse_notification(notification)
      new(notification).parse_notification
    end

    def generate_merchant_order_number
      %Q(OddPay::#{gateway_provider}::MerchantOrderNumberGenerator).
        constantize.
        call(gateway_source)
    end

    def generate_post_info(params)
      %Q(OddPay::#{gateway_provider}::PostInfoGenerator).
        constantize.
        call(gateway_source)

    def update_notification
      %Q(OddPay::#{gateway_provider}::NotificationUpdater).
        constantize.
        update(gateway_source)
    end

    def parse_notification
      %Q(OddPay::#{gateway_provider}::NotificationUpdater).
        constantize.
        parse_notification(gateway_source)
    end
  end
end
