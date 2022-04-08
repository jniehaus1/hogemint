module Alchemy
  class Transaction
    # URL: https://polygon-mainnet.g.alchemyapi.io/v2/your-api-key
    # RequestType: POST
    # Body:
    # {
    #     "jsonrpc":"2.0",
    #     "method":"eth_getTransactionByHash",
    #     "params":["0x4ec492e0ba174ddca1324e9867c4e4c10a6eca6a1f77b56a19de875ae869b195"],
    #     "id":0
    # }
    #
    def self.lookup(tx_hash:)
      # TODO - swap to polygon-mainnet.g.
      response = HTTParty.post("https://eth-rinkeby.alchemyapi.io/v2/#{ENV["ALCHEMY_API_KEY"]}",
                               body:    { jsonrpc: "2.0",
                                          method: "eth_getTransactionByHash",
                                          params: [tx_hash],
                                          id: "0" }.to_json,
                               headers: { 'Content-Type' => 'application/json' })

      return nil if response["error"].present?

      response
    end
  end
end
