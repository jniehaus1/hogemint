class CoingatesController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new {|c| c.request.format.json?}

  # https://developer.coingate.com/docs/payment-callback
  def callback
    return nil if params[:token].blank?

    sale = Sale.find_by(token: params[:token])
    return nil if sale.blank?

    if coingate_params[:status] == "paid"
      sale.pay!
      receipt = CoinGateReceipt.create(coingate_params.merge(sale_id: sale.id))
      if receipt.persisted?
        MintWorker.perform_async(receipt.id)
      else
        raise "Could not create coingate receipt"
      end
    else
      raise "Coingate callback shows status is not paid."
    end
  end

  private

  def coingate_params
    params.permit(:order_id, :status, :price_amount, :price_currency, :receive_currency, :receive_amount,
                  :pay_amount, :pay_currency, :underpaid_amount, :overpaid_amount, :is_refundable, :created_at)
  end
end
