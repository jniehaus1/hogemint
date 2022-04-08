module NowPayments
  # Creates a blockchain payment hook that watches for updates to the wallet
  # Example Response
  # {
  #     "payment_id": "5745459419",
  #     "payment_status": "waiting",
  #     "pay_address": "3EZ2uTdVDAMFXTfc6uLDDKR6o8qKBZXVkj",
  #     "price_amount": 3999.5,
  #     "price_currency": "usd",
  #     "pay_amount": 0.17070286,
  #     "pay_currency": "btc",
  #     "order_id": "RGDBP-21314",
  #     "order_description": "Apple Macbook Pro 2019 x 1",
  #     "ipn_callback_url": "https://nowpayments.io",
  #     "created_at": "2020-12-22T15:00:22.742Z",
  #     "updated_at": "2020-12-22T15:00:22.742Z",
  #     "purchase_id": "5837122679"
  # }
  #
  class CreatePayment
    include ApplicationService
    include Rails.application.routes.url_helpers

    def initialize(item:)
      @item = item
    end

    # https://documenter.getpostman.com/view/7907941/S1a32n38?version=latest#5e37f3ad-0fa1-4292-af51-5c7f95730486
    def call
      HTTParty.post("#{ENV["NP_API_URL"]}/v1/payment", {
          body: post_params.to_json,
          headers: headers
      })
    end

    private

    def post_params
      { :price_amount     => 50,
        :price_currency   => 'USD',
        :pay_currency     => 'ETH',
        :ipn_callback_url => ENV["NP_CALLBACK_URL"],
        :success_url      => success_url,
        :cancel_url       => root_url
      }
    end

    def headers
      { "x-api-key"    => ENV["NP_SANDBOX_API_KEY"],
        'Content-Type' => 'application/json'}
    end

    def success_url
      if @item.is_a?(Item)
        item_url(@item.id)
      elsif @item.is_a?(BaseItem)
        base_item_url(@item.id)
      else
        nil
      end
    end
  end
end
