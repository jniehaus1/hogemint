#
# Checks etherscan to see if transaction was submitted. (Pending) Tx are not reflected in this call, as they exist
# in etherscan's mempool.
#
class VerifyWorker
  include Sidekiq::Worker

  def perform(sale_id)
    return nil if Rails.env != "production"
    sale = Sale.find(sale_id)
    response = HTTParty.get("https://api.etherscan.io/api?module=localchk&action=txexist&txhash=#{sale.tx_hash}")

    raise "Error contacting etherscan: #{response}" if response["status"] != "1"

    if (response["result"] == "False")
      sale.fail_minting!
      MintWorker.perform_async(sale.id, sale.nft_asset.generation)
    end
    sale.finish_minting!
  end
end
