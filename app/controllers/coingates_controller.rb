class CoingatesController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new {|c| c.request.format.json?}

  # https://developer.coingate.com/docs/payment-callback
  def callback
    Rails.logger.warn(params)
    return nil if params[:token].blank?

    sale = Sale.find_by(token: params[:token])
    return nil if sale.blank?

    # No internal action to take
    return Rails.logger.info("Received coingate callback: #{params}") if coingate_params[:status] == "pending" || coingate_params[:status] == "new"

    # Move to unpaid state
    return cancel_sale(sale) if coingate_params[:status] == "canceled"

    raise "Coingate callback shows status is not paid: #{coingate_params}" if coingate_params[:status] != "paid"

    # Coingate sometimes sends multiple "paid" callbacks.
    return nil if CoinGateReceipt.find_by(sale_id: sale.id)

    sale.pay!
    receipt = CoinGateReceipt.create(coingate_params.merge(sale_id: sale.id))
    if receipt.persisted?
      MintWorker.perform_async(receipt.id)
    else
      raise "Could not create coingate receipt"
    end
  end

  private

  def cancel_sale(sale)
    sale.cancel!
  end

  def coingate_params
    params.permit(:order_id, :status, :price_amount, :price_currency, :receive_currency, :receive_amount,
                  :pay_amount, :pay_currency, :underpaid_amount, :overpaid_amount, :is_refundable, :remote_created_at,
                  :token)
  end
end
