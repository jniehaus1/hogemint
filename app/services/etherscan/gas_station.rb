module Etherscan
  class GasStation
    class << self
      def gas_price
        response = HTTParty.get("https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=#{ENV['ETHERSCAN_API_KEY']}")
        return -9999 if response["status"] == 0 || response["result"].blank? || response["result"]["ProposeGasPrice"].blank?
        response["result"]["ProposeGasPrice"].to_i
      end
    end
  end
end
