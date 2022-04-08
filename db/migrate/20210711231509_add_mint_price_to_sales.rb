class AddMintPriceToSales < ActiveRecord::Migration[5.2]
  def change
    add_column :sales, :mint_price, :string
  end
end
