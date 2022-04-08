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
    @item = Item.new(item_params)

    if @item.save
      redirect_to @item
    else
      flash[:item_errors] = @item.errors.full_messages
      render "shared/modal_errors", locals: { error_messages: @item.errors.full_messages }
    end
  end

  def show
    @item = Item.find_by(id: params[:id])
  end

  def edit
    @item = Item.find_by(id: params[:id])
  end

  def update; end

  def delete; end

  private

  def item_params
    params.require(:item).permit(:image, :owner, :nonce, :signed_msg, :title, :flavor_text)
  end
end
