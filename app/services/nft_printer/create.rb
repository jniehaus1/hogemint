module NftPrinter
  class Create
    include ApplicationService

    def initialize(item)
      @item = item
    end

    def call
      validate_inputs
      validate_uri

      contract = build_contract
      contract.transact_and_wait.mint(owner, uri)
    end

    def build_contract
      contract = Ethereum::Contract.create(name: "HogeNFT", address: ENV["CONTRACT_ADDRESS"], abi: abi, client: client)
      contract.key = private_key
      contract
    end

    def private_key
      @private_key ||= Eth::Key.new(priv: ENV["MINT_PRIVATE_KEY"])
    end

    def abi
      f = File.read("data/eth/HogeNFT.json");
      data_hash = JSON.parse(f);
      raise "Cannot find abi data from file" if data_hash["abi"].blank?
      data_hash["abi"]
    end

    def client
      @client = Ethereum::HttpClient.new(ENV["ETH_NODE"])
      @client.gas_limit = ENV["MINT_GAS_LIMIT"].to_i # In Gas: 250000 for example
      @client.gas_price = gas_price * 1000000000     # in Wei: 110000000000 for example
      @client
    end

    def gas_price
      response = HttParty.get("https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=#{ENV['ETHERSCAN_API_KEY']}")
      raise "Could not fetch gas price from Etherscan: #{response}" if response["result"]["ProposeGasPrice"].blank?
      response["result"]["ProposeGasPrice"].to_i
    end

    def validate_inputs
      raise "No CONTRACT_ADDRESS" if ENV["CONTRACT_ADDRESS"].blank?
      raise "No MINT_PRIVATE_KEY" if ENV["MINT_PRIVATE_KEY"].blank?
    end

    def validate_uri
      raise "Bad URI at ID: #{@item.id} URI: #{@item.uri}" unless @item.uri.match?(/\h{32}/)
    end
  end
end
