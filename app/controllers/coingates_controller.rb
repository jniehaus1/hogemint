class CoingatesController < ApplicationController
  # https://developer.coingate.com/docs/payment-callback
  def callback
    sale = Sale.find_by(token: coingate_params[:token])
    return nil if sale.blank?

    if coingate_params[:status] == "paid"
      sale.pay
      receipt = CoinGateReceipt.create(coingate_params)
      #queue NFT
    else
      # log and take no action
    end

  end

  private

  def coingate_params
    params.permit(:order_id, :status, :price_amount, :price_currency, :receive_currency, :receive_amount,
                  :pay_amount, :pay_currency, :underpaid_amount, :overpaid_amount, :is_refundable, :created_at, :token)
  end
end
