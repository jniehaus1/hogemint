module Etherscan
  class GasStation
    class << self
      def gas_price
        response = HTTParty.get("https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=#{ENV['ETHERSCAN_API_KEY']}")
        raise "Could not fetch gas price from Etherscan: #{response}" if response["result"]["FastGasPrice"].blank?
        response["result"]["ProposeGasPrice"].to_i
      end
    end
  end
end
