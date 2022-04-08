module NftPrinter
  class Create
    include ApplicationService

    def initialize(item, owner, mint_addr, private_key)
      @item  = item
      @owner = owner
      @mint_address = mint_addr
      @private_key_str = private_key
    end

    def call
      validate_inputs
      validate_uri

      contract = build_contract
      contract.transact_and_wait.mint(@owner, @item.uri)
    end

    def build_contract
      contract = Ethereum::Contract.create(name: "HogeNFTv2", address: @mint_address, abi: abi, client: client)
      contract.key = private_key
      contract
    end

    def private_key
      @private_key ||= Eth::Key.new(priv: @private_key_str)
    end

    def abi
      f = File.read("data/eth/HogeNFTv2.json");
      data_hash = JSON.parse(f);
      raise "Cannot find abi data from file" if data_hash["abi"].blank?
      data_hash["abi"]
    end

    def client
      @client = Ethereum::HttpClient.new(ENV["ETH_NODE"])
      @client.gas_limit = ENV["MINT_GAS_LIMIT"].to_i # In Gas: 250000 for example
      @client.gas_price = Etherscan::GasStation.gas_price * 1000000000 # in Wei: 110000000000 for example
      @client
    end

    def validate_inputs
      raise "No Owner Address" if @owner.blank?
      raise "Nothing to Mint, Item doesn't exist" if @item.blank?
      raise "No CONTRACT_ADDRESS" if @mint_address.blank?
      raise "No MINT_PRIVATE_KEY" if @private_key_str.blank?
    end

    def validate_uri
      raise "Bad URI at ID: #{@item.id} URI: #{@item.uri}" unless @item.uri.match?(/\h{32}/)
    end
  end
end
