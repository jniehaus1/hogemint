module Ipfs
  class Pinata
    include ApplicationService

    require "uri"
    require "net/http"

    # Taken from postman ruby example
    def self.pin_file(file_data)
      url = URI("https://api.pinata.cloud/pinning/pinFileToIPFS")

      https = Net::HTTP.new(url.host, url.port)

      https.use_ssl = true

      request = Net::HTTP::Post.new(url)

      request["pinata_api_key"] = ENV["PINATA_API_KEY"]

      request["pinata_secret_api_key"] = ENV["PINATA_API_SECRET"]

      file = Tempfile.new(:encoding => 'ascii-8bit')
      file << file_data
      file.rewind

      #['pinataOptions', '{"cidVersion":0}'],
      form_data = [['file', file]]

      request.set_form form_data, 'multipart/form-data'

      response = JSON.parse(https.request(request).read_body)

      Rails.logger.info(response)

      return response
    ensure
      file.close
      file.unlink
    end

    def self.pin_json(uri_hash)
      url = URI("https://api.pinata.cloud/pinning/pinJSONtoIPFS")

      https = Net::HTTP.new(url.host, url.port)

      https.use_ssl = true

      request = Net::HTTP::Post.new(url)

      request["pinata_api_key"] = ENV["PINATA_API_KEY"]

      request["pinata_secret_api_key"] = ENV["PINATA_API_SECRET"]

      request["Content-Type"] = "application/json"

      request.body = uri_hash.to_json

      return JSON.parse(https.request(request).read_body)
    end
  end
end
