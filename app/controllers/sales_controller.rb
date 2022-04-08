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
    gas_price = Etherscan::GasStation.gas_price
    return render_failed_etherscan_api if gas_price.negative?

    order_response = NowPayments::CreateInvoice.call(item: @item, gas_price: gas_price)
    return render_failed_api if order_response["message"].present?

    @sale = Sale.create(sale_params(order_response, gas_price))
    return render_failed_sale_create unless @sale.persisted?

    render checkout_partial, locals: { pay_address:        order_response["invoice_url"],
                                       gas_price:          @sale.gas_price,
                                       mint_price:         order_response["price_amount"],
                                       returning_checkout: false,
                                       payment_status:     { "message" => true } }
  end

  def return_checkout(checkout_partial)
    payment_status = NowPayments::Status.call(sale: @sale)
    fix_mint_price(@sale.gas_price) if @sale.mint_price == nil

    render checkout_partial, locals: { pay_address:        @sale.invoice_url,
                                       gas_price:          @sale.gas_price,
                                       mint_price:         @sale.mint_price,
                                       returning_checkout: true,
                                       payment_status:     payment_status }
  end

  def render_no_item
    @error_messages = ["You are attempting to checkout with an unknown item."]
  end

  def rend_failed_etherscan_api
    msg = "Failed to obtain a gas price for the ethereum network. Please refresh to try again."
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

  private

  def sale_params(order_response, gas_price)
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

  def fix_mint_price(gas_price)
    eth = ENV["MINT_GAS_LIMIT"].to_i * gas_price * 1e-9
    # https://api.nowpayments.io/v1/estimate?amount=3999.5000&currency_from=usd&currency_to=btc
    usd_response = HTTParty.get("#{ENV["NP_API_URL"]}/v1/estimate?amount=#{eth}&currency_from=eth&currency_to=usd", { headers: headers })
    gas_cost = usd_response["estimated_amount"].to_f

    price = gas_cost < 10 ? 25 : (gas_cost + 15)

    @sale.update(mint_price: price)
  end

  def now_payment_order_id(item)
    "NP_ORDER_#{item.order_id}"
  end

  def headers
    { "x-api-key"    => ENV["NP_API_KEY"],
      'Content-Type' => 'application/json'}
  end
end
