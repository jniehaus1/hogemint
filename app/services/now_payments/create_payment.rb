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

    def initialize(item:, gas_price:)
      @item = item
      @gas_price = gas_price
    end

    # https://documenter.getpostman.com/view/7907941/S1a32n38?version=latest#5e37f3ad-0fa1-4292-af51-5c7f95730486
    def call
      eth = ENV["GAS_TO_CHARGE"].to_i * @gas_price * 1e-9
      # https://api.nowpayments.io/v1/estimate?amount=3999.5000&currency_from=usd&currency_to=btc
      estimate_response = HTTParty.get("#{ENV["NP_API_URL"]}/v1/estimate?amount=#{eth}&currency_from=eth&currency_to=usd", { headers: headers })
      @price_amount = estimate_response["estimated_amount"]

      HTTParty.post("#{ENV["NP_API_URL"]}/v1/payment", {
          body: post_params.to_json,
          headers: headers
      })
    end

    private

    def post_params
      # :price_amount     => @price_amount,
      { :price_amount     => 59,
        :price_currency   => 'USD',
        :pay_currency     => 'XLM',
        :ipn_callback_url => ENV["NP_CALLBACK_URL"]
      }
    end

    def headers
      { "x-api-key"    => ENV["NP_API_KEY"],
        'Content-Type' => 'application/json'}
    end
  end
end
