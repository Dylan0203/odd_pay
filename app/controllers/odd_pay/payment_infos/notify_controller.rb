# require_dependency "odd_pay/application_controller"

module OddPay
  class PaymentInfos::NotifyController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      payment_info = PaymentInfo.find_by_hashid!(params[:payment_info_id])
      notification = payment_info.notifications.find_or_create_by!(
        raw_data: request.POST,
        reference: :payment_notify
      )

      if notification.previously_new_record?
        OddPay::PaymentGatewayService.update_notification(notification)
        OddPay::PaymentGatewayService.update_payment_info(payment_info)
        OddPay::PaymentGatewayService.update_invoice(payment_info.invoice)
      end

      render plain: '1|OK'
    end
  end
end
