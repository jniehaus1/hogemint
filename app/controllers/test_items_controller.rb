class TestItemsController < ItemsController
  def self.controller_path
    "items"
  end

  def index
    @items = TestItem.all
  end

  def new
    @item = TestItem.new
    @nonce = SecureRandom.uuid
  end

  def create
    @item = TestItem.new(item_params.slice(:owner, :image, :signed_msg, :nonce))

    if @item.save
      redirect_to @item
    else
      flash[:item_errors] = @item.errors.full_messages
      render "shared/modal_errors", locals: { error_messages: @item.errors.full_messages }
    end
  end

  def show
    @item = TestItem.find_by(id: params[:id])
  end

  def edit
    @item = TestItem.find_by(id: params[:id])
  end

  def update; end

  def delete; end

  private

  def item_params
    params.require(:test_item).permit(:image, :owner, :nonce, :signed_msg)
  end
end
