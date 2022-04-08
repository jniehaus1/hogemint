# == Schema Information
#
# Table name: nft_assets
#
#  id             :bigint           not null, primary key
#  nft_model_type :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class NftAsset < ApplicationRecord
  belongs_to :nft_model, polymorphic: true
end
