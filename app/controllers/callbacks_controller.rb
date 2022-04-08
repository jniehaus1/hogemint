class CallbacksController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new {|c| c.request.format.json?}

  def polygon
    Rails.logger.info("RECEIVED POLYGON CALLBACK")
    Rails.logger.info(params.to_s)

    @tx_hash = params[:receipt][:transactionHash]
    sale = Sale.includes(:nft_asset).find(params[:sale_id])
    item = sale.nft_asset
    msg = "This signature helps our server verify the transaction and attribute your nft. Unique Token: #{sale.nonce}"

    raise "Transaction already attributed to sale" if PolygonReceipt.find_by(tx_hash: @tx_hash).present?
    raise "Signature & Transfer wallet do not match." if key_owner(msg, params[:signed_msg]).downcase != tx_from_wallet.downcase
    raise "Not enough quid" if tx_value < ENV["MATIC_FEES"].to_f * 1e18
    raise "Didn't send money to the right wallet" if tx_to_wallet.downcase != ENV["CUSTODIAL_WALLET"].downcase

    PolygonReceipt.create!(amount:     ENV["MATIC_FEES"],
                           item:       item,
                           msg:        msg,
                           nonce:      sale.nonce,
                           sale:       sale,
                           signed_msg: params[:signed_msg],
                           tx_hash:    @tx_hash,
                           wallet:     tx_from_wallet)
    sale.pay!
    # MintWorker.perform_async(sale.id, item.generation)
  end

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

    sale = Sale.includes(:nft_asset).find_by(merchant_order_id: np_params[:order_id])
    return nil if sale.blank? # Could not find sale, :order_id missing somehow

    # Guard clause "new" callback is sent many times from NowPayments server
    return invoice_sale(sale) if np_params[:payment_status] == "waiting" && sale.aasm_state == "new"

    # Move to canceled state
    # Leave this commented, people can create multiple payments in NP and the first couple will trigger
    # a swap to the "failed" state even if a later transaction goes through.
    # return cancel_sale(sale) if ["failed", "refunded", "expired"].include?(np_params[:payment_status])

    # No internal action to take, receipt already exists
    return nil if NpReceipt.find_by(sale_id: sale.id)

    if np_params[:payment_status] == "finished"
      pay_sale(sale)
      NpReceipt.create!(np_params.merge(sale_id: sale.id))
      MintWorker.perform_async(sale.id, sale.nft_asset.generation)
    end

    head :no_content
  end

  private

  def key_owner(msg, signed_msg)
    Eth::Utils.public_key_to_address(key_from_msg(msg, signed_msg))
  end

  def key_from_msg(msg, signed_msg)
    Eth::Key.personal_recover(msg, signed_msg)
  end

  def tx_from_wallet
    tx_lookup["result"]["from"]
  end

  def tx_value
    tx_lookup["result"]["value"].to_i(16)
  end

  def tx_to_wallet
    tx_lookup["result"]["to"]
  end

  def tx_lookup
    @tx_lookup ||= Polygonscan::TxArbiter.lookup(tx_hash: @tx_hash)
  end

  def cancel_sale(sale)
    sale.cancel!
  end

  def pay_sale(sale)
    sale.update(payment_id: np_params[:payment_id])
    sale.pay!
  end

  def invoice_sale(sale)
    sale.update(payment_id: np_params[:payment_id])
    sale.invoice!
  end

  def np_params
    params.permit(:payment_id, :payment_status, :pay_address, :price_amount, :price_currency, :pay_amount, :actually_paid,
                  :pay_currency, :order_id, :order_description, :purchase_id, :outcome_amount, :outcome_currency)
  end
end
