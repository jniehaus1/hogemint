class AddImageHashToItem < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :image_hash, :string
  end
end
