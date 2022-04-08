class BaseItemsController < ApplicationController
  before_action :check_session_pw, except: [:new_session, :login, :show]

  # I know it's bad, and I just don't care right now.
  # Will implement devise in the future.
  def login
    if params[:password] == ENV["SESSION_PW"]
      session[:pw] = ENV["SESSION_PW"]
      redirect_to new_base_item_url
    else
      redirect_to new_session_url
    end
  end

  def new_session; end

  def new
    @base_item = BaseItem.new
  end

  # TODO - Move to behind devise wall
  def create
    @base_item = BaseItem.create(base_item_params)
    return render_new_with_errors if @base_item.errors.present?

    redirect_to sales_base_checkout_url(@base_item)
  end

  def show
    @base_item = BaseItem.includes(:sales).find_by(id: params[:id])
    sale = @base_item.sales.first
    @receipt = sale&.np_receipt
  end

  def skip_payment
    @base_item = BaseItem.includes(:sales).find_by(id: params[:id])
    sale = @base_item.sales.first
    sale.invoice!
    sale.pay!
    MintWorker.perform_async(sale.id, sale.nft_asset.generation)

    redirect_to base_item_url(@base_item)
  end

  def check_session_pw
    redirect_to :new_session if session[:pw] != ENV["SESSION_PW"]
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
end
