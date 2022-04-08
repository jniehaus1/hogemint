# == Schema Information
#
# Table name: sales
#
#  id               :bigint           not null, primary key
#  quantity         :integer
#  gas_for_mint     :integer
#  nft_owner        :string
#  gas_price        :float
#  status           :string
#  coingate_receipt :integer
#  token            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require 'test_helper'

class SaleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
