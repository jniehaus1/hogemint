class AddNftAssetToSales < ActiveRecord::Migration[5.2]
  def change
    add_column :sales, :nft_asset_type, :string
  end
end
