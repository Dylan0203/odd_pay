module OddPay
  class PaymentGatewayService
    include OddPay::Composables::PaymentGatewayApiClient

    AVAILABLE_GATEWAYS = %i(NewebPay).freeze
    REQUIRED_GATEWAY_INFO = {
      NewebPay: %i(hash_iv hash_key merchant_id)
    }.freeze
    NORMAL_PAYMENT_TYPES = %i(
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
    ).freeze
    SUBSCRIPTION_PAYMENT_TYPES = %i(
      subscription
    ).freeze
    PAYMENT_TYPES = (
      NORMAL_PAYMENT_TYPES +
        SUBSCRIPTION_PAYMENT_TYPES
    ).freeze
    AVAILABLE_PAYMENT_TYPE_MAP = {
      normal: NORMAL_PAYMENT_TYPES,
      subscription: SUBSCRIPTION_PAYMENT_TYPES
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

    def self.update_payment_info(payment_info)
      OddPay::PaymentGatewayService::PaymentInfoUpdater.update(payment_info)
    end

    def self.update_invoice(invoice)
      OddPay::PaymentGatewayService::InvoiceUpdater.update(invoice)
    end

    def self.cancel_invoice(invoice)
      last_payment_info = invoice.payment_infos.paid.last
      new(last_payment_info).cancel_payment_info
    end

    def self.expired_payment_infos_processer
      OddPay::PaymentInfo.
        expired.
        find_each(batch_size: 100) do |payment_info|
          OddPay::PaymentGatewayService::PaymentInfoExpireUpdater.update(payment_info)
        end
    end

    def generate_merchant_order_number
      %Q(OddPay::#{gateway_provider}::MerchantOrderNumberGenerator).
        constantize.
        call(gateway_source)
    end

    def generate_post_info(params)
      %Q(OddPay::#{gateway_provider}::PostInfoGenerator).
        constantize.
        call(gateway_source, params)
    end

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

    def cancel_payment_info
      %Q(OddPay::#{gateway_provider}::PaymentInfoCanceler).
        constantize.
        call(gateway_source)
    end
  end
end
