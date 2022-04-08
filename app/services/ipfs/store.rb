module Ipfs
  class Store
    include ApplicationService

    def initialize(sale)
      @sale = sale
      @item = sale.nft_asset
    end

    # Upload file to Pinata
    # Get IPFS File hash
    # Post for IPFS URI hash
    # Update Item URI
    def call
      # ["IpfsHash", "PinSize", "Timestamp", "isDuplicate"]
      response = Ipfs::Pinata.pin_file(base64_image)
      raise("PINATA API ERROR: #{response["error"]} on SALE: #{sale.as_json}") if response["error"].present?

      json_response = Ipfs::Pinata.pin_json(uri_hash(response))
      @item.update(ipfs_file_cid: response["IpfsHash"], ipfs_json_cid: json_response["IpfsHash"])
    end

    private

    def base64_image
      Paperclip.io_adapters.for(@item.meme_card).read
    end

    def uri_hash(response)
      Hash.new(image: "ipfs://#{response['IpfsHash']}")
    end
  end
end
