class RemoveStatusFromSale < ActiveRecord::Migration[5.2]
  def change
    remove_column :sales, :status
  end
end
