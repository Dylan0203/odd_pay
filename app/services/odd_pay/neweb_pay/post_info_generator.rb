module OddPay
  module NewebPay
    class PostInfoGenerator
      include OddPay::Composables::PaymentGatewayApiClient
      include OddPay::Composables::DefaultUrlOptions

      attr_reader :payment_info, :params, :payment_type, :invoice

      PAYMENT_METHOD_PARAMS = {
        credit_card: {
          CREDIT: 1
        },
        vacc: {
          VACC: 1
        },
        webatm: {
          WEBATM: 1
        },
        credit_card_inst_3: {
          InstFlag: 3
        },
        credit_card_inst_6: {
          InstFlag: 6
        },
        credit_card_inst_12: {
          InstFlag: 12
        },
        credit_card_inst_18: {
          InstFlag: 18
        },
        credit_card_inst_24: {
          InstFlag: 24
        },
        credit_card_inst_30: {
          InstFlag: 30
        },
        android_pay: {
          ANDROIDPAY: 1
        },
        samsung_pay: {
          SAMSUNGPAY: 1
        },
        union_pay: {
          UNIONPAY: 1
        },
        cvs: {
          CVS: 1
        },
        barcode: {
          BARCODE: 1
        },
        cvscom: {
          CVSCOM: 2
        }
      }.freeze

      SUBSCRIPTION_API_END_POINTS = {
        test: 'https://ccore.newebpay.com/MPG/period',
        production: 'https://core.newebpay.com/MPG/period'
      }.freeze

      NORMAL_PAYMENT_API_END_POINTS = {
        test: 'https://ccore.newebpay.com/MPG/mpg_gateway',
        production: 'https://core.newebpay.com/MPG/mpg_gateway'
      }.freeze

      def initialize(payment_info, params)
        @gateway_source = payment_info
        @payment_info = payment_info
        @params = params
        @payment_type = payment_info.payment_type
        @invoice = payment_info.invoice
      end

      def self.call(payment_info, params)
        new(payment_info, params).call
      end

      def call
        api_mode = api_client.options[:mode]
        case payment_type
        when :subscription
          {
            post_url: SUBSCRIPTION_API_END_POINTS[api_mode],
            post_params: api_client.generate_period_params(subscription_post_params)
          }
        else
          {
            post_url: NORMAL_PAYMENT_API_END_POINTS[api_mode],
            post_params: api_client.generate_mpg_params_20(
              normal_post_params.
                merge(normal_payment_method_params)
            )
          }
        end
      end

      private

      def normal_payment_method_params
        PAYMENT_METHOD_PARAMS[payment_type]
      end

      def subscription_post_params
        {
          MerOrderNo: merchant_order_number,
          ProdDesc: item_description,
          PeriodAmt: payment_amount,
          PeriodType: period_type,
          PeriodPoint: period_point,
          PeriodStartType: 2, # 交易模式 1=立即執行十元授權 2=立即執行委託金額授權 3=不檢查信用卡資訊，不授權
          PeriodTimes: invoice.period_times.to_s,
          ReturnURL: thanks_for_purchase_url,
          PayerEmail: email,
          NotifyURL: notify_url,
          BackURL: back_url
        }.compact
      end

      def normal_post_params
        {
          MerchantOrderNo: merchant_order_number,
          Amt: payment_amount,
          ItemDesc: item_description,
          Email: email,
          EmailModify: 0,
          LoginType: 0,
          OrderComment: nil,
          ReturnURL: thanks_for_purchase_url,
          NotifyURL: notify_url,
          CustomerURL: async_payment_url,
          ClientBackURL: back_url,
          ExpireDate: nil # TODO:
        }.compact
      end

      def notify_url
        Engine.routes.url_helpers.payment_info_notify_url({ payment_info_id: payment_info.hashid }.merge(default_url_optoins))
      end

      def back_url
        params[:back_url] ||
          Rails.application.routes.url_helpers.root_url(default_url_optoins)
      end

      def thanks_for_purchase_url
        params[:thanks_for_purchase_url] ||
          Engine.routes.url_helpers.payment_info_thanks_for_purchase_url({ payment_info_id: payment_info.hashid }.merge(default_url_optoins))
      end

      def async_payment_url
        params[:async_payment_url] ||
          Engine.routes.url_helpers.payment_info_async_payment_url({ payment_info_id: payment_info.hashid }.merge(default_url_optoins))
      end

      def expire_date
        params[:expire_date]
      end

      def email
        invoice.email
      end

      def merchant_order_number
        payment_info.merchant_order_number
      end

      def payment_amount
        payment_info.amount.to_i
      end

      def item_description
        compose_item_info = ->(acc, item) do
          acc << %Q(#{item.name}＊#{item.quantity})
        end

        invoice.
          items.
          inject([], &compose_item_info).
          join('／').
          truncate(100)
      end

      def period_type
        case invoice.period_type
        when :days
          'D'
        when :weeks
          'W'
        when :months
          'M'
        when :years
          'Y'
        end
      end

      def period_point
        # 1.修改此委託於週期間，執行信用卡授權交易的時間點
        # 2.當 PeriodType = D，此欄位值限為數字 2~999，以授權日期隔日起算。
        #   例：數值為 2，則表示每隔兩天會執行一次委託
        # 3.當 PeriodType =W，此欄位值限為數字 1~7，代表每週一至週日。
        #   例：每週日執行授權，則此欄位值為 7；若週日與週一皆需執行授權，請分別建立 2 張委託
        # 3.當 PeriodType = M，此欄位值限為數字 01~31，代表每月 1 號~31 號。若當月沒該日期則由該月的最後一天做為扣款日
        #   例：每月 1 號執行授權，則此欄位值為 01；若於 1 個月內需授權多次，請以建立多次委託方式執行。
        # 5.當 PeriodType =Y，此欄位值格式為 MMDD 例：每年的 3 月 15 號執行授權，則此欄位值為 0315；若於 1 年內需授權多次，請以建立多次委託方式執行
        current_time = Time.current
        case period_type
        when 'D'
          invoice.period_point.to_s
        when 'W'
          current_time.strftime('%u')
        when 'M'
          current_time.strftime('%d')
        when 'Y'
          current_time.strftime('%m%d')
        end
      end
    end
  end
end
