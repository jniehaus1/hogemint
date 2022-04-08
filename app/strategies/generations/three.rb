module Generations
  class Three
    MINT_ADDR = ENV["GEN_TWO_MINT_ADDRESS"].freeze

    def initialize(item:)
      @item = item
    end

    def run_validations; end

    def generate_card
      Vips::Compile.new(@item).preview
    end
  end
end
