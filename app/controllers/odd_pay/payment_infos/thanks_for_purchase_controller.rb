# require_dependency "odd_pay/application_controller"

module OddPay
  class PaymentInfos::ThanksForPurchaseController < ApplicationController
    skip_before_action :verify_authenticity_token

    def show
      redirect_to main_app.root_path
    end

    def create
      payment_info = PaymentInfo.find_by_hashid!(params[:payment_info_id])
      notification = payment_info.notifications.new(
        raw_data: request.POST,
        reference: :payment_notify
      )

      @info = notification.compose_info

      render :show
    end
  end
end
