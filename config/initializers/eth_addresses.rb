if Rails.env != "test"
  require 'smarter_csv'

  HexConverter = Object.new
  def HexConverter.convert(value)
    value.hex
  end

  # HOGE_HOLDERS = SmarterCSV.process("data/hoge_holders.csv", value_converters: { holderaddress: HexConverter }).pluck(:holderaddress).sort
  # HOGE_HOLDERS_EXPANSION = SmarterCSV.process("data/hoge_holders_expansion.csv", value_converters: { holderaddress: HexConverter }).pluck(:holderaddress).sort
  HOGE_HOLDERS_GALAXY = SmarterCSV.process("data/hoge_holders_galaxy.csv", value_converters: { holderaddress: HexConverter }).pluck(:holderaddress).sort
  HOGE_HOLDERS_GALAXY.append(SmarterCSV.process("data/hoge_holders_galaxy_bsc.csv", value_converters: { holderaddress: HexConverter }).pluck(:holderaddress).sort)
end
