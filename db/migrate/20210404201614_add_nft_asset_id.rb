class AddNftAssetId < ActiveRecord::Migration[5.2]
  def change
    add_column :sales, :nft_asset_id, :integer
  end
end
