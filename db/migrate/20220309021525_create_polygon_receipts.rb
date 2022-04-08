class CreatePolygonReceipts < ActiveRecord::Migration[5.2]
  def change
    create_table :polygon_receipts do |t|
      t.string  :amount
      t.integer :item_id
      t.string  :msg
      t.string  :nonce
      t.integer :sale_id
      t.string  :signed_msg
      t.string  :tx_hash
      t.string  :wallet

      t.timestamps
    end
  end
end
