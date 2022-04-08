class CreateNowPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :now_payments do |t|
      t.string  :payment_id
      t.string  :payment_status
      t.string  :price_amount
      t.string  :price_currency
      t.string  :pay_amount
      t.string  :pay_currency
      t.string  :order_id
      t.string  :order_description
      t.string  :ipn_callback_url
      t.string  :purchase_id
      t.timestamps
    end
  end
end
