class GravityWellWorker
  include Sidekiq::Worker

  def perform(item_id)
    item = Item.find(item_id)

    # Trigger image processing
    response = HTTParty.post(ENV["API_GATEWAY_URL"],
                             body:    item_params(item).to_json,
                             headers: { 'Content-Type' => 'application/json',
                                        'x-api-key' => ENV["API_GATEWAY_KEY"]})

    return Sidekiq.logger.error("Failed to process file for Item: #{item_id} " \
                                "with: #{response["errorMessage"]}") if response["errorMessage"].present?
    response_body = JSON.parse(response["body"])
    return Sidekiq.logger.error("Failed to process file for Item: #{item_id} " \
                                "with: #{response_body["error"]}") if response_body["error"].present?

    item.update!(generated_gif_url: rensponse_body["url"])

    # Upload to ipfs
    upload_to_ipfs(item, response_body["url"])

    item.processing = false
    item.save!
  rescue Net::ReadTimeout => e
    Sidekiq.logger.error(e)
    # can just wait for uploaded file to appear
  rescue StandardError => e
    Sidekiq.logger.error(e)
    # Do nothing, fail so we don't continually ping Lambda or IPFS uploads
  end

  def upload_to_ipfs(item, url)
    url = response_body["url"]

    tmpfile = Tempfile.new(image_key(item))
    tmpfile.binmode
    tmpfile.write(HTTParty.get(url).body)
    tmpfile.rewind
    Ipfs::Store.call(item, tmpfile.read)
    tmpfile.close
    tmpfile.unlink
  end

  def item_params(item)
    {
      file_key:    item.image.path,
      title:       item.title,
      flavor_text: item.flavor_text,
      uri:         item.uri
    }
  end

  def local_path(image)
    "/tmp/#{image_key(image)}"
  end

  def image_key(item)
    MD5::Digest.hexdigest(item.image.path)
  end
end
