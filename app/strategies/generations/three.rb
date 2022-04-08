module Generations
  class Three
    MINT_ADDR = ENV["GEN_TWO_MINT_ADDRESS"].freeze

    def initialize(item:); end

    def run_validations(); end

    def generate_card(); end
  end
end
