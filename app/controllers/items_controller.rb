class ItemsController < ApplicationController
  def index
    @items = Item.all
  end

  def new
    @item = Item.new
  end

  def create
    # im = Magick::Image.from_blob(item_params[:image]) if item_params[:image].present?
    # im2 = Magick::Image.read("data/hoge_logo.jpg")
    # im2[0].composite(im[0],0,0, Magick::OverCompositeOp).display
    # im[0].display

    return nil unless HOGE_HOLDERS.include?(item_params[:owner].hex)

    @item = Item.create(item_params)

    if @item.save
      redirect_to @item
    else
      redirect_to failed_url
    end
  end

  def failed; end

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
    params.require(:item).permit(:image, :owner)
  end
end
