include ApplicationHelper

class ItemsController < ApplicationController
  MSG_PREFIX = "We generated a token to prove that you're you! Sign with your account to protect your data. Unique Token: "

  def index
    @items = Item.all
  end

  def new
    @item = Item.new
    @nonce = SecureRandom.uuid
  end

  def create
    @item = Item.new(item_params.merge(image_hash.merge({ generation: ENV["CURRENT_GENERATION"] })))

    if @item.save
      redirect_to @item
    else
      flash[:item_errors] = @item.errors.full_messages
      render "shared/modal_errors", locals: { error_messages: @item.errors.full_messages }
    end
  end

  def uri
    item = Item.find_by(uri: short_uri) || BaseItem.find_by(uri: short_uri)

    # Should move image_link call to model & have them share a common interface
    image_link = if item.is_a?(Item)
                   fix_s3_link(item&.meme_card)
                 elsif item.is_a?(BaseItem)
                   fix_s3_link(item&.image)
                 else
                   nil
                 end

    msg = {
        "name": "Hoge Foundation NFT",
        "image": image_link,
        "description": "Minted from the crucible of based memes."
    }

    render json: msg
  end

  def show
    @item = Item.includes(:sales).find_by(id: params[:id])
    @sale = @item.sales.first
  end

  def edit
    @item = Item.find_by(id: params[:id])
  end

  # Same flow as BaseItems#create
  def remint
    return nil unless ENV["ALLOW_REMINT"] == "true"
    @item = Item.find_by(id: params[:id])

    order_response = CoinGate::Orders::Create.call(item: @item)
    return render_failed_coingate_api if order_response.status != "new"

    @sale = Sale.create(remint_params(order_response))
    return render_failed_sale_create if @sale.errors.present?

    render "shared/coingate_link.js.erb", locals: { coingate_url: order_response.payment_url }
  end

  private

  def remint_params(order_response)
    { quantity:     1,
      gas_for_mint: ENV["MINT_GAS_LIMIT"],
      gas_price:    Etherscan::GasStation.gas_price,
      token:        order_response.token,
      nft_asset:    @item,
      nft_owner:    @item.owner }
  end

  def render_failed_coingate_api
    render "shared/modal_errors", locals: { error_messages: "Failed to create order in CoinGate API." }
  end

  def render_failed_sale_create
    render "shared/modal_errors", locals: { error_messages: @sale.errors.full_messages }
  end

  def item_params
    params.require(:item).permit(:image, :owner, :nonce, :signed_msg, :title, :flavor_text)
  end

  def image_hash
    return { image_hash: nil } if item_params[:image].blank?

    myhash = Digest::MD5.hexdigest(item_params[:image].read)
    item_params[:image].rewind
    { image_hash: myhash }
  end

  # Legacy code to handle 64 len strings
  def short_uri
    return nil unless params[:id].size >= 32
    params[:id][0..31] if params[:id].present?
  end
end
