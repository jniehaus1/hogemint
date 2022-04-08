class GalaxyWorker
  include Sidekiq::Worker
  include Sidekiq::Lock::Worker

  # static lock that expires after one second
  sidekiq_options lock: { timeout: 20000, name: 'lock-worker' }

  def perform(item_id)
    if lock.acquire!
      begin
        item = Item.find(item_id)

        gif = Vips::Compile.new(item).gif
        item.meme_card = gif
        item.processing = false
        item.save!
      ensure
        # You probably want to manually release lock after work is done
        # This method can be safely called even if lock wasn't acquired
        # by current worker (thread). For more references see RedisLock class
        lock.release!
      end
    else
      raise "Could not acquire lock! Retrying!"
    end
  end
end
