include ApplicationHelper

class ItemsController < ApplicationController
  before_action :empty_errors

  MSG_PREFIX = "We generated a token to prove that you're you! Sign with your account to protect your data. Unique Token: "

  def index
    @items = Item.where(is_flagged: false)
  end

  def new
    @item = Item.new
    @nonce = SecureRandom.uuid
    @gas_prices = Etherscan::GasStation.gas_prices
  end

  def create
    if @item.blank?
      @item = Item.new(item_params.merge(image_hash.merge({ generation: ENV["CURRENT_GENERATION"] })))
      @item.save
    else
      @error_messages = ["You've already started making an NFT, please continue with the checkout process."]
    end

    return render_failed_item_create unless @item.persisted?

    redirect_to sales_checkout_url(@item)
  end

  def uri
    item = Item.find_by(uri: short_uri) || BaseItem.find_by(uri: short_uri)

    # Should move image_link call to model & have them share a common interface
    image_link = ""
    nft_url    = ""
    if item.is_a?(Item)
      image_link = fix_s3_link(item&.meme_card)
      nft_url = item_url(item)
    elsif item.is_a?(BaseItem)
      image_link = fix_s3_link(item&.image)
      nft_url = base_item_url(item)
    end

    msg = {
        "name":        item.uri_name,
        "image":       image_link,
        "description": "Minted from the crucible of based memes.",
        "nft_url":     nft_url,
        "created_at":  item.created_at
    }

    render json: msg
  end

  def show
    @item = Item.includes(:sales).find_by(id: params[:id])
    @sale = @item.sales.first
  end

  private

  def render_failed_item_create
    @error_messages = @item.errors.full_messages
    render :new
  end

  def item_params
    params.require(:item).permit(:image, :owner, :nonce, :signed_msg, :title, :flavor_text, :agreement)
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

  def use_ipfs?
    !(ENV["CURRENT_GENERATION"] == "one" || ENV["CURRENT_GENERATION"] == "two" || ENV["CURRENT_GENERATION"] == "three")
  end

  def empty_errors
    @error_messages = []
  end
end
