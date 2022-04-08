module NowPayments
  # Example Response:
  # {
  #     "payment_id": 5524759814,
  #     "payment_status": "finished",
  #     "pay_address": "TNDFkiSmBQorNFacb3735q8MnT29sn8BLn",
  #     "price_amount": 5,
  #     "price_currency": "usd",
  #     "pay_amount": 165.652609,
  #     "actually_paid": 180,
  #     "pay_currency": "trx",
  #     "order_id": "RGDBP-21314",
  #     "order_description": "Apple Macbook Pro 2019 x 1",
  #     "purchase_id": "4944856743",
  #     "created_at": "2020-12-16T14:30:43.306Z",
  #     "updated_at": "2020-12-16T14:40:46.523Z",
  #     "outcome_amount": 178.9005,
  #     "outcome_currency": "trx"
  # }
  class Status
    include ApplicationService

    def initialize(sale:)
      @sale = sale
    end

    # https://documenter.getpostman.com/view/7907941/S1a32n38?version=latest#0b77a8e3-2344-4760-a0bd-247da067db6d
    def call
      HTTParty.get("#{ENV["NP_API_URL"]}/v1/payment/#{@sale.payment_id}", {
          headers: headers
      })
    end

    private

    def headers
      { "x-api-key"    => ENV["NP_SANDBOX_API_KEY"],
        'Content-Type' => 'application/json'}
    end
  end
end
