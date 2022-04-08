module Polygonscan
  class GasStation
    class << self
      def gas_price
        response = HTTParty.get("https://api.polygonscan.com/api?module=gastracker&action=gasoracle&apikey=#{ENV['POLYGONSCAN_API_KEY']}")
        return -9999 if response["status"] == 0 || response["result"].blank? || response["result"]["ProposeGasPrice"].blank?
        response["result"]["ProposeGasPrice"].to_i
      end

      def gas_prices
        response = HTTParty.get("https://api.polygonscan.com/api?module=gastracker&action=gasoracle&apikey=#{ENV['POLYGONSCAN_API_KEY']}")
        return -9999 if response["status"] == 0 || response["result"].blank? || response["result"]["ProposeGasPrice"].blank?
        response["result"]
      end
    end
  end
end
