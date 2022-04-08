class SalesController < ApplicationController
  def checkout
    @item = Item.includes(:sales).find_by(id: params[:id])
    return render_no_item unless @item.present?

    @sale = @item.sales.first
    @error_messages = []

    if @sale.blank?
      new_checkout("checkout")
    else
      return_checkout("checkout")
    end
  end

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

  def new_checkout(checkout_partial)
    @gas_price = Etherscan::GasStation.gas_price()
    order_response = NowPayments::CreateInvoice.call(item: @item, gas_price: @gas_price)
    return render_failed_api if order_response["message"].present?

    @sale = Sale.create(sale_params(order_response))
    return render_failed_sale_create if @sale.errors.present?

    render checkout_partial, locals: { pay_address: order_response["invoice_url"], gas_price: @gas_price, returning_checkout: false }
  end

  def return_checkout(checkout_partial)
    render checkout_partial, locals: { pay_address: @sale.invoice_url, gas_price: Etherscan::GasStation.gas_price, returning_checkout: true }
  end

  def render_no_item
    @error_messages = ["You are attempting to checkout with an unknown item."]
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

  private

  def sale_params(order_response)
    {
      nft_asset:    @item,
      nft_owner:    @item.owner,
      quantity:     1,
      gas_for_mint: ENV["MINT_GAS_LIMIT"],
      gas_price:    @gas_price,
      invoice_url:  order_response["invoice_url"],
      merchant_order_id: "NP_ORDER_#{@item.order_id}"
    }
  end
end
