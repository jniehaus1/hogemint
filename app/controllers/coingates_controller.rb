class CoingatesController < ApplicationController
  # https://developer.coingate.com/docs/payment-callback
  def callback
    binding.pry
  end

  private

  def coingate_params
    params.permit(:id, :order_id, :status, :price_amount, :price_currency, :receive_currency, :receive_amount,
                  :pay_amount, :pay_currency, :underpaid_amount, :overpaid_amount, :is_refundable, :created_at, :token)
  end
end
