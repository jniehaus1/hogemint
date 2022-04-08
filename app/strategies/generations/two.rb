module Generations
  class Two
    MINT_ADDR = ENV["GEN_TWO_MINT_ADDRESS"].freeze
    MSG_PREFIX = "We generated a token to prove that you're you! Sign with your account to protect your data. Unique Token: ".freeze

    def initialize(item:)
      @item = item
    end

    # Take no action
    def generate_card
      Items::CardGeneratorExpansion.call(@item)
    end

    def run_validations
      owner_matches_signed_msg
      owner_is_unique
      owner_has_hoge
      image_exists
    end

    def owner_matches_signed_msg
      return nil if key_owner == @item.owner

      @item.errors.add(:base, "Owner does not match signed message. Did you use the correct wallet?")
    end

    def key_owner
      # Assert validations
      Eth::Utils.public_key_to_address(key_from_msg)
    end

    def key_from_msg
      # Assert validations
      Eth::Key.personal_recover(MSG_PREFIX + @item.nonce, @item.signed_msg)
    end

    def owner_is_unique
      return nil unless Item.where(owner: @item.owner, generation: ENV["CURRENT_GENERATION"]).present?

      @item.errors.add(:base, "Owner address has already been used!")
      throw(:abort)
    end

    def owner_has_hoge
      return nil if HOGE_HOLDERS_EXPANSION.include?(@item.owner.hex)

      @item.errors.add(:base, "Owner wallet must have contained HOGE tokens BEFORE May 8th 04:00 UTC")
      throw(:abort)
    end

    def image_exists
      return nil if @item.image.present?

      @item.errors.add(:base, "You must provide an image")
      throw(:abort)
    end
  end
end
