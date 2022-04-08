class CreateSales < ActiveRecord::Migration[5.2]
  def change
    create_table :sales do |t|
      t.integer :quantity
      t.integer :gas_for_mint
      t.string  :nft_owner
      t.integer :nft_asset_id
      t.float   :gas_price
      t.string  :status
      t.integer :coingate_receipt
      t.string  :token

      t.timestamps
    end
  end
end
