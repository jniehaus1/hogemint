class NftAsset < ApplicationRecord
  belongs_to :nft_model, polymorphic: true
end
