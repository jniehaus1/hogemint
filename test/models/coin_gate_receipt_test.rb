# == Schema Information
#
# Table name: coin_gate_receipts
#
#  id                :bigint           not null, primary key
#  token             :string
#  status            :string
#  price_currency    :string
#  price_amount      :string
#  receive_currency  :string
#  receive_amount    :string
#  remote_created_at :string
#  order_id          :string
#  payment_url       :string
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
