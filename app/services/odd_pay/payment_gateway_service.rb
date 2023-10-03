module OddPay
  class PaymentGatewayService
    include OddPay::Composables::PaymentGatewayApiClient

    AVAILABLE_GATEWAYS = %i(NewebPay Offline).freeze
    REQUIRED_GATEWAY_INFO = {
      NewebPay: %i(hash_iv hash_key merchant_id),
      Offline: %i()
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
      offline_payment
      linepay
      taiwan_pay
      esun_wallet
      ezpay
      alipay
      wechat_pay
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
    PAYMENT_TYPE_AMOUNT_LIMIT_MAP = {
      NewebPay: {
        default: 199_999,
        vacc: 49_999,
        webatm: 49_999
      }
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

    def self.apply_refund(payment, amount: nil)
      new(payment).apply_refund(amount)
    end

    def self.cancel_payment_info(payment_info, amount: nil)
      new(payment_info).cancel_payment_info(amount)
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

    def cancel_payment_info(amount)
      %Q(OddPay::#{gateway_provider}::PaymentInfoCanceler).
        constantize.
        call(gateway_source, amount: amount)
    end

    def apply_refund(amount)
      %Q(OddPay::#{gateway_provider}::RefundApplier).
        constantize.
        call(gateway_source, amount)
    end
  end
end
