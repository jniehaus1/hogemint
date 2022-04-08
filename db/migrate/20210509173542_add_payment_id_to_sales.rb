class AddPaymentIdToSales < ActiveRecord::Migration[5.2]
  def change
    add_column :sales, :payment_id, :string
  end
end
