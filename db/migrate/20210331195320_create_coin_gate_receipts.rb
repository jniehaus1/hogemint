class CreateCoinGateReceipts < ActiveRecord::Migration[5.2]
  def change
    create_table :coin_gate_receipts do |t|
      t.string :invoice_id
      t.string :status
      t.string :price_currency
      t.string :price_amount
      t.string :receive_currency
      t.string :receive_amount
      t.string :pay_amount
      t.string :pay_currency
      t.string :underpaid_amount
      t.string :overpaid_amount
      t.string :is_refundable
      t.string :remote_created_at
      t.string :order_id
      t.integer :sale_id

      t.timestamps
    end
  end
end
