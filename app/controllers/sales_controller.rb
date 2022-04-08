class SalesController < ApplicationController
  def base_checkout
    @item = BaseItem.includes(:sales).find_by(id: params[:id])
    return render_no_item unless @item.present?

    @sale = @item.sales.first
    @error_messages = []

    if @sale.blank?
      new_checkout("base_checkout")
    else
      return_checkout("base_checkout")
    end
  end

  def checkout
    @item = Item.includes(:sales).find_by(id: params[:id])
    return render_no_item unless @item.present?

    @nonce = SecureRandom.uuid
    @sale = @item.sales.first
    @error_messages = []

    if @sale.blank?
      new_checkout("checkout")
    else
      return_checkout("checkout")
    end
  end

  private

  def new_checkout(checkout_partial)
    gas_price = Polygonscan::GasStation.gas_price
    return render_failed_etherscan_api if gas_price.negative?

    @sale = Sale.create(sale_params(gas_price))
    return render_failed_sale_create unless @sale.persisted?

    render checkout_partial, locals: { mint_price: @sale.mint_price }
  end

  def return_checkout(checkout_partial)
    render checkout_partial, locals: { mint_price: @sale.mint_price }
  end

  def np_sale_params(order_response, gas_price)
    {
      nft_asset:    @item,
      nft_owner:    @item.owner,
      quantity:     1,
      gas_for_mint: ENV["MINT_GAS_LIMIT"],
      gas_price:    gas_price,
      mint_price:   order_response["price_amount"],
      invoice_url:  order_response["invoice_url"],
      merchant_order_id: now_payment_order_id(@item)
    }
  end

  def sale_params(gas_price)
    {
        nft_asset:    @item,
        nft_owner:    @item.owner,
        quantity:     1,
        gas_for_mint: ENV["MINT_GAS_LIMIT"],
        gas_price:    gas_price,
        mint_price:   ENV["MATIC_FEES"],
    }
  end

  def now_payment_order_id(item)
    "NP_ORDER_#{item.order_id}"
  end

  def render_no_item
    @error_messages = ["You are attempting to checkout with an unknown item."]
  end

  def render_failed_etherscan_api
    msg = "Failed to obtain a gas price for the network. Please refresh to try again."
    Rails.logger.error(msg)
    @error_messages = [msg]
  end

  def render_failed_api
    msg = "Failed to create your order. Return to #{item_url(@item)} after contacting support@hoge.finance to finish the nft creation process."
    Rails.logger.error(msg)
    @error_messages = [msg]
  end

  def render_failed_return
    msg = "Failed to find your order in our payment processor. Please contact support@hoge.finance with your NFT link handy for help. #{item_url(@item)}"
    Rails.logger.error(msg)
    @error_messages = [msg]
  end

  def render_failed_sale_create
    msg = "Return to #{item_url(@item)} after contacting support to finish the nft creation process."
    Rails.logger.error(msg)
    @error_messages = @sale.errors.full_messages.merge(msg)
  end
end
