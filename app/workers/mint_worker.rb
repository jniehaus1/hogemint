class MintWorker
  include Sidekiq::Worker

  def perform(sale_id, generation)
    sale = Sale.find(sale_id)
    sale.mint! # Advance sale state

    nft_asset = sale.nft_asset
    if generation == "two"
      NftPrinter::Create.call(nft_asset, sale.nft_owner, mint_address(generation), private_key(generation))
      sale.finish_minting!
    elsif generation == "one"
      NftPrinter::CreateGenOne.call(nft_asset, sale.nft_owner, mint_address(generation), private_key(generation))
      sale.finish_minting!
    else
      sale.fail_minting!
      raise "Cannot mint, not generation 1 or 2."
    end
  rescue Timeout::Error => e
    Rails.logger.error("Timed out minting sale #{sale.id}: #{e}")
  rescue StandardError => e
    sale.fail_minting! # Move to failed state
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
