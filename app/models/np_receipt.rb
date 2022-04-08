# == Schema Information
#
# Table name: np_receipts
#
#  id                :bigint           not null, primary key
#  payment_id        :string
#  payment_status    :string
#  pay_address       :string
#  price_amount      :string
#  price_currency    :string
#  pay_amount        :string
#  actually_paid     :string
#  pay_currency      :string
#  order_id          :string
#  order_description :string
#  purchase_id       :string
#  outcome_amount    :string
#  outcome_currency  :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class NpReceipt < ApplicationRecord
  belongs_to :sale
end
