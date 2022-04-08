class SalesController < ApplicationController
  def checkout
    @item = Item.includes(:sales).find_by(id: params[:id])
    return render_no_item unless @item.present?

    @sale = @item.sales.first
    @error_messages = []

    if @sale.blank?
      new_checkout
    else
      return_checkout
    end
  end

  def new_checkout
    order_response = NowPayments::CreatePayment.call(item: @item)
    return render_failed_api if order_response["payment_status"] != "waiting"

    @sale = Sale.create(sale_params(order_response))
    return render_failed_sale_create if @sale.errors.present?

    render "checkout", locals: { pay_address: order_response["pay_address"], gas_price: Etherscan::GasStation.gas_price, pay_status: "waiting" }
  end

  def return_checkout
    order_response = NowPayments::Status.call(sale: @sale)

    return render_failed_return if order_response["message"].present? # Nothing found or bad URL
    render "checkout", locals: { pay_address: order_response["pay_address"], gas_price: Etherscan::GasStation.gas_price, pay_status: order_response["payment_status"] }
  end

  def render_no_item
    @error_messages = ["You are attempting to checkout with an unknown item."]
  end

  def render_failed_api
    @error_messages = ["Failed to create your order. Return to #{item_url(@item)} after contacting support@hoge.finance to finish the nft creation process."]
  end

  def render_failed_return
    @error_messages = ["Failed to find your order in our payment processor. Please contact support@hoge.finance with your NFT link handy for help. #{item_url(@item)}"]
  end

  def render_failed_sale_create
    @error_messages = @sale.errors.full_messages.merge("Return to #{item_url(@item)} after contacting support to finish the nft creation process.")
  end

  private

  def sale_params(order_response)
    { quantity:     1,
      gas_for_mint: ENV["MINT_GAS_LIMIT"],
      gas_price:    Etherscan::GasStation.gas_price,
      payment_id:   order_response["payment_id"],
      nft_asset:    @item,
      nft_owner:    @item.owner }
  end
end
