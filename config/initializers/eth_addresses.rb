require 'smarter_csv'

HexConverter = Object.new
def HexConverter.convert(value)
  value.hex
end

HOGE_HOLDERS = SmarterCSV.process("data/hoge_holders.csv", value_converters: { holderaddress: HexConverter }).pluck(:holderaddress).sort
