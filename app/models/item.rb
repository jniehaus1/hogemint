# == Schema Information
#
# Table name: items
#
#  id         :bigint           not null, primary key
#  token_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uri        :string
#  owner      :string
#
class Item < ApplicationRecord
  has_one_attached :image

  validates :owner, presence: true, format: { with: /[0][x]\h{40}/, message: "Must be a valid wallet address" }
  validates :image, presence: true, blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg'], size_range: 0..5.megabytes }
  validate :owner_is_unique
  validate :owner_has_hoge

  before_create :generate_uri

  def generate_uri
    # stuff
  end

  def owner_is_unique
    return nil unless Item.find_by(owner: owner).present?

    errors.add(:base, "Wallet address must be unique. It has already been used!")
    throw(:abort)
  end

  def owner_has_hoge
    return nil unless HOGE_HOLDERS.include?(item_params[:owner].hex)

    errors.add(:base, "Wallet address must contain HOGE tokens.")
    throw(:abort)
  end
end
