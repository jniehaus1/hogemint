include ApplicationHelper

class ItemsController < ApplicationController
  MSG_PREFIX = "We generated a token to prove that you're you! Sign with your account to protect your data. Unique Token: "

  def index
    @items = Item.all.reject { |item| item.is_flagged }
  end

  def new
    @item = Item.new
    @nonce = SecureRandom.uuid
  end

  def create
    @item = Item.new(item_params.merge(image_hash.merge({ generation: ENV["CURRENT_GENERATION"] })))
    @item.save

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
        "name":        uri_name(item),
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

  def edit
    @item = Item.find_by(id: params[:id])
  end

  private

  def uri_name(item)
    if item.generation == "one"
      "Hoge Foundation NFT"
    elsif item.generation == "two"
      "Hoge Expansion NFT"
    else
      "Hoge NFT"
    end
  end

  def render_failed_item_create
    flash[:item_errors] = @item.errors.full_messages
    render "shared/modal_errors", locals: { error_messages: @item.errors.full_messages }
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
