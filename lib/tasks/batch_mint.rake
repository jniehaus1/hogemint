desc "Mint a batch of Items, specified by IDs"

namespace :hoge do
  task :batch_mint => :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    validate_inputs
    items = Item.where(id: ARGV[1].to_i..ARGV[2].to_i)
    validate_data(items)

    c = contract
    items.each do |i|
      puts i.owner
    end
  end

  def contract
    contract = Ethereum::Contract.create(name: "HogeNFT", address: ENV["CONTRACT_ADDRESS"], abi: abi, client: client)
    contract.key = private_key
    contract
  end

  def private_key
    @private_key ||= Eth::Key.new(priv: ENV["MINT_PRIVATE_KEY"])
  end

  def abi
    f = File.read("data/eth/HogeNFT.json");
    data_hash = JSON.parse(f);
    raise "Cannot find abi data from file" if data_hash["abi"].blank?
    data_hash["abi"]
  end

  def client
    @client ||= Ethereum::HttpClient.new("HTTP://127.0.0.1:7545")
  end

  def validate_inputs
    raise "No CONTRACT_ADDRESS" if ENV["CONTRACT_ADDRESS"].blank?
    raise "No MINT_PRIVATE_KEY" if ENV["MINT_PRIVATE_KEY"].blank?
  end

  def validate_data(items)
    raise "Malformed URI" unless all_uris_valid?(items)
  end

  def all_uris_valid?(items)
    items.each do |i|
      raise "Bad URI at ID: #{i.id} URI: #{i.uri}" unless i.uri.match?(/\h{32}/)
    end
  end
end
