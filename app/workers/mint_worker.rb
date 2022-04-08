class MintWorker
  include Sidekiq::Worker

  def perform(receipt_id, generation)
    receipt = NpReceipt.find_by(id: receipt_id)
    sale = receipt.sale
    sale.mint! # Advance sale state

    nft_asset = receipt.sale.nft_asset
    NftPrinter::Create.call(nft_asset, sale.nft_owner, mint_address(generation), private_key(generation))

    receipt.sale.finish_minting!
  rescue StandardError => e
    receipt.sale.fail_minting! # Move to failed state
    raise e # Reraise
  end

  private

  def mint_address(generation)
    ENV["GEN_#{generation.upcase}_MINT_ADDRESS"]
  end

  def private_key(generation)
    ENV["GEN_#{generation.upcase}_MINT_PRIVATE_KEY"]
  end
end
