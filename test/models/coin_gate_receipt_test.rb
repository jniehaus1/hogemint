# == Schema Information
#
# Table name: coin_gate_receipts
#
#  id                :bigint           not null, primary key
#  invoice_id        :string
#  status            :string
#  price_currency    :string
#  price_amount      :string
#  receive_currency  :string
#  receive_amount    :string
#  pay_amount        :string
#  pay_currency      :string
#  underpaid_amount  :string
#  overpaid_amount   :string
#  is_refundable     :string
#  remote_created_at :string
#  order_id          :string
#  sale_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require 'test_helper'

class CoinGateReceiptTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
