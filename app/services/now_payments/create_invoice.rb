module NowPayments
  # Example Response:
  # {
  #   "id": "4522625843",
  #   "order_id": "RGDBP-21314",
  #   "order_description": "Apple Macbook Pro 2019 x 1",
  #   "price_amount": "1000",
  #   "price_currency": "usd",
  #   "pay_currency": null,
  #   "ipn_callback_url": "https://nowpayments.io",
  #   "invoice_url": "https://nowpayments.io/payment/?iid=4522625843",
  #   "success_url": "https://nowpayments.io",
  #   "cancel_url": "https://nowpayments.io",
  #   "created_at": "2020-12-22T15:05:58.290Z",
  #   "updated_at": "2020-12-22T15:05:58.290Z"
  # }
  #
  class CreateInvoice
    include ApplicationService
    include Rails.application.routes.url_helpers

    def initialize(item:, gas_price:)
      @item = item
      @gas_price = gas_price
    end

    def call
      if ENV["FAKE_INVOICE"] == "true"
        return fake_invoice
      else
        return HTTParty.post("#{ENV["NP_API_URL"]}/v1/invoice", {
            body: post_params.to_json,
            headers: headers
          })
      end
    end

    private

    # {
    #     "price_amount": 1000,
    #     "price_currency": "usd",
    #     "order_id": "RGDBP-21314",
    #     "order_description": "Apple Macbook Pro 2019 x 1",
    #     "ipn_callback_url": "https://nowpayments.io",
    #     "success_url": "https://nowpayments.io",
    #     "cancel_url": "https://nowpayments.io"
    # }
    def post_params
      {
        :price_amount     => mint_price,
        :price_currency   => 'HOGE',
        :order_id         => "NP_FALSE_#{@item.order_id}",
        :ipn_callback_url => ENV["NP_CALLBACK_URL"],
        :success_url      => success_url,
        :cancel_url       => root_url
      }
    end

    # $25 USD equivalent if gas < $10
    # else gas + $15
    def mint_price
      eth = ENV["MINT_GAS_LIMIT"].to_i * @gas_price * 1e-9
      # https://api.nowpayments.io/v1/estimate?amount=3999.5000&currency_from=usd&currency_to=btc
      usd_response = HTTParty.get("#{ENV["NP_API_URL"]}/v1/estimate?amount=#{eth}&currency_from=eth&currency_to=usd", { headers: headers })
      gas_cost = usd_response["estimated_amount"].to_f

      usd_price = gas_cost < 10 ? 25 : (gas_cost + 15)
      hoge_response = HTTParty.get("#{ENV["NP_API_URL"]}/v1/estimate?amount=#{usd_price}&currency_from=usd&currency_to=hoge", { headers: headers })

      (usd_price - gas_cost)

      hoge_response["estimated_amount"].to_f.ceil
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

    def headers
      { "x-api-key"    => ENV["NP_API_KEY"],
        'Content-Type' => 'application/json'}
    end

    def fake_invoice
      {
          "id" => "4522625843",
          "order_id" => "RGDBP-21314",
          "order_description" => "Apple Macbook Pro 2019 x 1",
          "price_amount" => "1000",
          "price_currency" => "hoge",
          "pay_currency" => nil,
          "ipn_callback_url" => "https://nowpayments.io",
          "invoice_url" => "https://nowpayments.io/payment/?iid=4522625843",
          "success_url" => "https://nowpayments.io",
          "cancel_url"  => "https://nowpayments.io",
          "created_at"  => "2020-12-22T15:05:58.290Z",
          "updated_at"  => "2020-12-22T15:05:58.290Z"
      }
    end
  end
end
