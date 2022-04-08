class GalaxyWorker
  include Sidekiq::Worker

  def perform(item_id)
    item = Item.find(item_id)

    gif = Vips::Compile.new(item).gif
    item.meme_card = gif
    item.processing = false
    item.save
  end
end
