class CreateCoinGateReceipts < ActiveRecord::Migration[5.2]
  def change
    create_table :coin_gate_receipts do |t|
      t.string :token
      t.string :status
      t.string :price_currency
      t.string :price_amount
      t.string :receive_currency
      t.string :receive_amount
      t.string :remote_created_at
      t.string :order_id
      t.string :payment_url
      t.integer :sale_id

      t.timestamps
    end
  end
end
