class CallbacksController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new {|c| c.request.format.json?}

  # Example Callback:
  # {
  # "payment_id":5077125051,
  # "payment_status":"waiting",
  # "pay_address":"0xd1cDE08A07cD25adEbEd35c3867a59228C09B606",
  # "price_amount":170,
  # "price_currency":"usd",
  # "pay_amount":155.38559757,
  # "actually_paid":0,
  # "pay_currency":"mana",
  # "order_id":"2",
  # "order_description":"Apple Macbook Pro 2019 x 1",
  # "purchase_id":"6084744717",
  # "created_at":"2021-04-12T14:22:54.942Z",
  # "updated_at":"2021-04-12T14:23:06.244Z",
  # "outcome_amount":1131.7812095,
  # "outcome_currency":"trx"
  # }
  #
  # payment_status: [waiting, confirming, confirmed, sending, partially_paid, finished, failed, refunded, expired]
  def now_payments
    Rails.logger.info("RECEIVED NOWPAYMENTS CALLBACK")

    # :message is used to signal error
    return nil if params[:message].present?

    # Could not find sale, :order_id missing somehow
    sale = Sale.find_by(merchant_order_id: np_params[:order_id])
    return nil if sale.blank?

    # Guard clause "new" callback is sent many times from NowPayments server
    return invoice_sale(sale) if np_params[:payment_status] == "waiting" && sale.aasm_state == "new"

    # Move to canceled state
    return cancel_sale(sale) if ["failed", "refunded", "expired"].include?(np_params[:payment_status])

    # No internal action to take, receipt already exists
    return nil if NpReceipt.find_by(sale_id: sale.id)

    if np_params[:payment_status] == "finished"
      sale.pay!
      receipt = NpReceipt.create(np_params.merge(sale_id: sale.id))
      if receipt.persisted?
        MintWorker.perform_async(sale.id, sale.nft_asset.generation)
      else
        raise "Could not create NowPayment receipt"
      end
    end

    head :no_content
  end

  # https://developer.coingate.com/docs/payment-callback
  def coingate
    Rails.logger.info("Received coingate callback: #{params}")

    return nil if params[:token].blank?

    sale = Sale.find_by(token: params[:token])
    return nil if sale.blank?

    # No internal action to take
    return nil if coingate_params[:status] == "pending" || coingate_params[:status] == "new"

    # Move to canceled state
    return cancel_sale(sale) if ["expired", "invalid", "canceled"].include?(coingate_params[:status])

    # Coingate sometimes sends multiple "paid" callbacks.
    return nil if CoinGateReceipt.find_by(sale_id: sale.id)

    raise "Coingate callback shows status is not paid: #{coingate_params}" if coingate_params[:status] != "paid"

    sale.pay!
    receipt = CoinGateReceipt.create(coingate_params.merge(sale_id: sale.id))
    if receipt.persisted?
      MintWorker.perform_async(receipt.id, sale.nft_asset.generation)
    else
      raise "Could not create coingate receipt"
    end

    head :no_content
  end

  private

  def cancel_sale(sale)
    sale.cancel!
  end

  def invoice_sale(sale)
    sale.update(payment_id: np_params[:payment_id])
    sale.invoice!
  end

  def coingate_params
    params.permit(:order_id, :status, :price_amount, :price_currency, :receive_currency, :receive_amount,
                  :pay_amount, :pay_currency, :underpaid_amount, :overpaid_amount, :is_refundable, :remote_created_at)
  end

  def np_params
    params.permit(:payment_id, :payment_status, :pay_address, :price_amount, :price_currency, :pay_amount, :actually_paid,
                  :pay_currency, :order_id, :order_description, :purchase_id, :outcome_amount, :outcome_currency)
  end
end
