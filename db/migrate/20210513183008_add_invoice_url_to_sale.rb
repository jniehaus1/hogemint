class AddInvoiceUrlToSale < ActiveRecord::Migration[5.2]
  def change
    add_column :sales, :invoice_url, :string
  end
end
