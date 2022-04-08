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
    item = Item.find_by(uri: short_uri)

    msg = {
      "name": "Hoge Foundation NFT",
      "image": fix_s3_link(item&.meme_card),
      "description": "Minted from the crucible of based memes."
    }
    render json: msg
  end

  def show
    @item = Item.find_by(id: params[:id])
  end

  def edit
    @item = Item.find_by(id: params[:id])
  end

  private

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
