class MintWorker
  include Sidekiq::Worker

  def perform(receipt_id)
    receipt = CoinGateReceipt.find_by(id: receipt_id)
    sale = receipt.sale
    sale.mint! # Advance sale state

    nft_asset = receipt.sale.nft_asset
    NftPrinter::Create.call(nft_asset, sale.nft_owner)

    receipt.sale.finish_minting!
  rescue StandardError => e
    receipt.sale.fail_minting! # Move to failed state
    raise e # Reraise
  end
end
