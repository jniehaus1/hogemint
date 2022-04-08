module Ipfs
  class Store
    include ApplicationService

    def initialize(item, meme_image)
      @item = item
      @meme_image = meme_image
    end

    # Upload file to Pinata
    # Get IPFS File hash
    # Post for IPFS URI hash
    # Update Item URI
    def call
      # ["IpfsHash", "PinSize", "Timestamp", "isDuplicate"]
      response = Ipfs::Pinata.pin_file(@meme_image)
      raise("PINATA FILE API ERROR: #{response["error"]} on ITEM: #{@item.as_json}") if response["error"].present?

      json_response = Ipfs::Pinata.pin_json(uri_hash(response))
      raise("PINATA URI API ERROR: #{json_response["error"]} on ITEM: #{@item.as_json}") if json_response["error"].present?

      @item.update(ipfs_meme_file_cid: response["IpfsHash"], ipfs_meme_json_cid: json_response["IpfsHash"])
    end

    private

    # def base64_image
    #   Paperclip.io_adapters.for(@item.image).read
    # end

    # TODO - Add other fields
    def uri_hash(response)
      { image: "ipfs://#{response['IpfsHash']}" }
    end
  end
end
