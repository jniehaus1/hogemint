class DropNftAssetTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :nft_assets
  end
end
