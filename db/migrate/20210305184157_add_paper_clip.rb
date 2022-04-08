class AddPaperClip < ActiveRecord::Migration[5.2]
  def change
    add_attachment :items, :image
    add_attachment :items, :meme_card
    add_attachment :test_items, :image
    add_attachment :test_items, :meme_card
  end
end
