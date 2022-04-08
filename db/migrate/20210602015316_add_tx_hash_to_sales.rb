class AddTxHashToSales < ActiveRecord::Migration[5.2]
  def change
    add_column :sales, :tx_hash, :string
  end
end
