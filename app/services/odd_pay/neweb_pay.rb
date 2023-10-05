module OddPay
  module NewebPay
    AVAILABLE_PAYMENT_TYPES = %i(
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
      linepay
      taiwan_pay
      esun_wallet
      ezpay
      alipay
      wechat_pay
    ).freeze

    EWALLET_PAYMENT_TYPES = %i(
      linepay
      taiwan_pay
      esun_wallet
      ezpay
      alipay
      wechat_pay
    ).freeze

    def self.parse_time(time_string, format: '%Y-%m-%d %H:%M:%S')
      time_string.in_time_zone if time_string
    rescue ArgumentError
      DateTime.
        strptime(time_string, format).
        to_s(:db).
        in_time_zone
    end
  end
end
