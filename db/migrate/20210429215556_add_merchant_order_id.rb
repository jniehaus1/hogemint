class AddMerchantOrderId < ActiveRecord::Migration[5.2]
  def change
    add_column :sales, :merchant_order_id, :string
    add_column :sales, :coingate_order_id, :string
  end
end
