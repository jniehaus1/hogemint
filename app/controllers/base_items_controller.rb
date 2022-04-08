class BaseItemsController < ApplicationController
  before_action :check_session_pw, except: [:new_session, :login, :show]

  # I know it's bad, and I just don't care right now.
  # Will implement devise in the future.
  def login
    if params[:password] == ENV["SESSION_PW"]
      session[:pw] = "sexy-beast"
      redirect_to new_base_item_url
    else
      redirect_to "new_session"
    end
  end

  def new_session; end

  def new
    @base_item = BaseItem.new
  end

  def create
    @base_item = BaseItem.create(base_item_params)
    return render_new_with_errors if @base_item.errors.present?

    order_response = CoinGate::Orders::Create.call(item: @base_item)
    return render_failed_coingate_api if order_response.status != "new"

    @sale = Sale.create(sale_params(order_response))
    return render_failed_sale_create if @sale.errors.present?

    render "base_items/create", locals: { coingate_url: order_response.payment_url }
  end

  def show
    @base_item = BaseItem.find_by(id: params[:id])
  end

  def check_session_pw
    redirect_to :new_session if session[:pw] != "sexy-beast"
  end

  private

  def render_new_with_errors
    render "shared/modal_errors", locals: { error_messages: @base_item.errors.full_messages }
  end

  def render_failed_coingate_api
    render "shared/modal_errors", locals: { error_messages: "Failed to create order in CoinGate API." }
  end

  def render_failed_sale_create
    render "shared/modal_errors", locals: { error_messages: @sale.errors.full_messages }
  end

  def base_item_params
    params.require(:base_item).permit(:owner, :image)
  end

  def sale_params(order_response)
    { quantity:     1,
      gas_for_mint: ENV["MINT_GAS_LIMIT"],
      gas_price:    Etherscan::GasStation.gas_price,
      token:        order_response.token,
      nft_asset:    @base_item,
      nft_owner:    @base_item.owner }
  end
end
