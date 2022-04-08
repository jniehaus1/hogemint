desc "Set the generation of all items to one"

namespace :hoge do
  task :set_generation => :environment do
    items = Item.all

    items.each do |item|
      puts "Updating Item: #{item.id}"
      item.update_attribute('generation', 1)
    end
  end
end
