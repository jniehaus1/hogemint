class AddNpReceipt < ActiveRecord::Migration[5.2]
  # {
  # "payment_id":5077125051,
  # "payment_status":"waiting",
  # "pay_address":"0xd1cDE08A07cD25adEbEd35c3867a59228C09B606",
  # "price_amount":170,
  # "price_currency":"usd",
  # "pay_amount":155.38559757,
  # "actually_paid":0,
  # "pay_currency":"mana",
  # "order_id":"2",
  # "order_description":"Apple Macbook Pro 2019 x 1",
  # "purchase_id":"6084744717",
  # "created_at":"2021-04-12T14:22:54.942Z",
  # "updated_at":"2021-04-12T14:23:06.244Z",
  # "outcome_amount":1131.7812095,
  # "outcome_currency":"trx"
  # }
  def change
    create_table :np_receipts do |t|
      t.string  :payment_id
      t.string  :payment_status
      t.string  :pay_address
      t.string  :price_amount
      t.string  :price_currency
      t.string  :pay_amount
      t.string  :actually_paid
      t.string  :pay_currency
      t.string  :order_id
      t.string  :order_description
      t.string  :purchase_id
      t.string  :outcome_amount
      t.string  :outcome_currency
      t.timestamps
    end
  end
end
