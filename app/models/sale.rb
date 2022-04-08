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
class Sale < ApplicationRecord
  include AASM

  has_one :coin_gate_receipt

  aasm do
    state :new, initial: true
    state :unpaid, :paid, :minting, :failed_to_mint, :done

    event :pay do
      transitions from: [:new, :unpaid], to: :paid
    end

    event :cancel_payment do
      transitions from: :new, to: :unpaid
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
