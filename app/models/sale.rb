# == Schema Information
#
# Table name: sales
#
#  id                :bigint           not null, primary key
#  quantity          :integer
#  gas_for_mint      :integer
#  nft_owner         :string
#  nft_asset_id      :integer
#  gas_price         :float
#  coingate_receipt  :integer
#  token             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  aasm_state        :string
#  nft_asset_type    :string
#  merchant_order_id :string
#  coingate_order_id :string
#  payment_id        :string
#
class Sale < ApplicationRecord
  include AASM

  has_one    :coin_gate_receipt
  has_one    :np_receipt
  belongs_to :nft_asset, polymorphic: true

  aasm do
    state :new, initial: true
    state :canceled, :paid, :minting, :failed_to_mint, :done

    event :pay do
      transitions from: :new, to: :paid
    end

    event :cancel do
      transitions from: :new, to: :canceled
    end

    event :mint do
      transitions from: [:paid, :failed_to_mint], to: :minting
    end

    event :fail_minting do
      transitions from: :minting, to: :failed_to_mint
    end

    event :finish_minting do
      transitions from: :minting, to: :done
    end
  end
end
