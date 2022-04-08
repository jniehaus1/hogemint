desc "Mint a batch of Items, specified by IDs"

task :batch_mint do
  items = Item.all
  items.each do |i|
    puts i.owner
  end
end
