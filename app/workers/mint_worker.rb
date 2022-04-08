class MintWorker
  include Sidekiq::Worker

  def perform(sale_id, generation)
    sale = Sale.find(sale_id)
    sale.mint! # Advance sale state

    nft_asset = sale.nft_asset
    if generation == "two"
      NftPrinter::Create.call(nft_asset, sale.nft_owner, mint_address(generation), private_key(generation))
    elsif generation == "one"
      NftPrinter::CreateGenOne.call(nft_asset, sale.nft_owner, mint_address(generation), private_key(generation))
    else
      raise "Cannot mint, not generation 1 or 2."
    end

    sale.finish_minting!
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
