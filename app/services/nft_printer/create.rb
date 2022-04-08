module NftPrinter
  class Create
    include ApplicationService

    def initialize(item)
      @item = item
    end

    def call
      validate_inputs
      validate_data

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
      @client.gas_limit = 2000000 # In Gas: 2_000_000
      @client.gas_price = 110000000000 # in Wei: 110_000_000_000
      @client
    end

    def validate_inputs
      raise "No CONTRACT_ADDRESS" if ENV["CONTRACT_ADDRESS"].blank?
      raise "No MINT_PRIVATE_KEY" if ENV["MINT_PRIVATE_KEY"].blank?
    end

    def validate_data
      raise "Malformed URI" unless uri_valid?
    end

    def uri_valid?
      raise "Bad URI at ID: #{@item.id} URI: #{@item.uri}" unless @item.uri.match?(/\h{16}/)
    end
  end
end
