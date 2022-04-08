class TestItemsController < ItemsController
  def self.controller_path
    "items"
  end

  # def index
  #   @items = TestItem.all
  # end

  def new
    @item = TestItem.new
    @nonce = SecureRandom.uuid
    render "items/news"
  end

  def create
    @item = TestItem.new(item_params.merge(image_hash))

    if @item.save
      redirect_to @item
    else
      render "shared/modal_warnings", locals: { warning_messages: @item.errors.full_messages }
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
    params.require(:test_item).permit(:image, :owner, :nonce, :signed_msg, :title, :flavor_text)
  end

  def image_hash
    return { image_hash: nil } if item_params[:image].blank?

    myhash = Digest::MD5.hexdigest(item_params[:image].read)
    item_params[:image].rewind
    { image_hash: myhash }
  end
end
