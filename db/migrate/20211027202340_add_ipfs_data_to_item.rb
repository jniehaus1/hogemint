class AddIpfsDataToItem < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :ipfs_image_file_cid, :string
    add_column :items, :ipfs_image_json_cid, :string
    add_column :items, :ipfs_meme_file_cid, :string
    add_column :items, :ipfs_meme_json_cid, :string
  end
end
