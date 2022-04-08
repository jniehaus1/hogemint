FactoryGirl.define do
  factory :item, class: Item do
    owner      { "0xB6cbE18aF2ADb6DB54825C6D69da25DaB0e5717D" }
    image      { FFaker::Image.file  }
    nonce      { (FFaker::Random.rand * 100).floor.to_s }
    signed_msg { "0x76e01859d6cf4a8637350bdb81e3cef71e29b7c2" } # Garbage msg
    generation { "three" }
  end
end
