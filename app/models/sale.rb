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
#  invoice_url       :string
#  tx_hash           :string
#  mint_price        :string
#
class Sale < ApplicationRecord
  include AASM

  has_one    :coin_gate_receipt
  has_one    :np_receipt
  belongs_to :nft_asset, polymorphic: true

  aasm do
    state :new, initial: true
    state :canceled, :invoiced, :paid, :minting, :pending_tx, :failed_to_mint, :done

    event :invoice do
      transitions from: :new, to: :invoiced
    end

    event :pay do
      transitions from: :invoiced, to: :paid
    end

    event :cancel do
      transitions to: :canceled
    end

    event :mint do
      transitions from: [:paid, :failed_to_mint], to: :minting
    end

    event :submit_tx do
      transitions from: :minting, to: :pending_tx
    end

    event :fail_minting do
      transitions from: [:minting, :pending_tx], to: :failed_to_mint
    end

    event :finish_minting do
      transitions from: :pending_tx, to: :done
    end
  end
end
