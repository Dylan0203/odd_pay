# require_dependency "odd_pay/application_controller"

module OddPay
  class PaymentInfos::AsyncPaymentController < ApplicationController
    skip_before_action :verify_authenticity_token

    def show
      redirect_to main_app.root_path
    end

    def create
      payment_info = PaymentInfo.find_by_hashid!(params[:payment_info_id])
      notification = payment_info.notifications.create_or_find_by!(
        raw_data: request.POST,
        reference: :async_payment_notify
      )

      if notification.previously_new_record?
        notification.update_info
        payment_info.update_info
        payment_info.invoice.update_info
      end

      @info = notification.information

      render :show
    end
  end
end
