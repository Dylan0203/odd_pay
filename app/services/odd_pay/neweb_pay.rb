module OddPay
  module NewebPay
    AVAILABLE_PAYMENT_METHODS = %i(
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
    ).freeze
  end
end