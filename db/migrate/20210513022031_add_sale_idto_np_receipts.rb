class AddSaleIdtoNpReceipts < ActiveRecord::Migration[5.2]
  def change
    add_column :np_receipts, :sale_id, :integer
  end
end
