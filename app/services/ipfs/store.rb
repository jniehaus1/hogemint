module Ipfs
  include Rails.application.routes.url_helpers

  class Store
    include ApplicationService

    def initialize(item, file_data)
      @item = item
      @file_data = file_data
    end

    # Upload file to Pinata
    # Get IPFS File hash
    # Post for IPFS URI hash
    # Update Item URI
    def call
      # ["IpfsHash", "PinSize", "Timestamp", "isDuplicate"]
      response = Ipfs::Pinata.pin_file(@file_data)
      raise("PINATA FILE API ERROR: #{response["error"]} on ITEM: #{@item.as_json}") if response["error"].present?

      json_response = Ipfs::Pinata.pin_json(uri_hash(response))
      raise("PINATA URI API ERROR: #{json_response["error"]} on ITEM: #{@item.as_json}") if json_response["error"].present?

      @item.update(ipfs_meme_file_cid: response["IpfsHash"], ipfs_meme_json_cid: json_response["IpfsHash"])
    end

    private

    def uri_hash(response)
      {
        "name":        @item.uri_name,
        "image":       "ipfs://#{response['IpfsHash']}",
        "description": "Minted from the crucible of based memes.",
        # "nft_url":     item_url(@item),
        "created_at":  @item.created_at
      }
    end
  end
end
