module Generations
  class Zero
    MINT_ADDR = "0x624f36C23b63F574565e9c60903ed765364566d1".freeze

    def initialize(item:)
      @item = item
    end

    def generate_card
      @item.meme_card = @item.image
      @item.save(validate: false)
    end
  end
end
