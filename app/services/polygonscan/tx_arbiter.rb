module Polygonscan
  class TxArbiter
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
    def self.verify(tx_hash:, from:)
      response = HTTParty.post("https://polygon-mainnet.g.alchemyapi.io/v2/#{ENV["ALCHEMY_API_KEY"]}",
                               body:    { jsonrpc: "2.0",
                                          method: "eth_getTransactionByHash",
                                          params: [tx_hash],
                                          id: "0" }.to_json,
                               headers: { 'Content-Type' => 'application/json' })

      return nil if response["error"].present?

      return from == response["result"]["from"] && transferred_value(response)
    end

    private

    def transferred_value
      response["result"]["value"].to_i(16) >= ENV["MATIC_FEES"].to_i * 1e18
    end
  end
end
