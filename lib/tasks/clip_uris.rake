desc "Clip uris to 32 length"

namespace :hoge do
  task :clip_uris => :environment do
    items = Item.all

    items.each do |item|
      item.update_attribute('uri', item.uri[0..31])
    end
  end
end
