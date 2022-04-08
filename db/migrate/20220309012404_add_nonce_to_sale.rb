class AddNonceToSale < ActiveRecord::Migration[5.2]
  def change
    add_column :sales, :nonce, :string
  end
end
