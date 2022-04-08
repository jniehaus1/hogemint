FactoryGirl.define do
  factory :sale, class: Sale do
    gas_price { (FFaker::Random.rand * 100).floor.to_s }
  end
end
