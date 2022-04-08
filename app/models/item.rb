# == Schema Information
#
# Table name: items
#
#  id                     :bigint           not null, primary key
#  token_id               :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  uri                    :string
#  owner                  :string
#  image_hash             :string
#  flavor_text            :string
#  title                  :string
#  image_file_name        :string
#  image_content_type     :string
#  image_file_size        :bigint
#  image_updated_at       :datetime
#  meme_card_file_name    :string
#  meme_card_content_type :string
#  meme_card_file_size    :bigint
#  meme_card_updated_at   :datetime
#  generation             :integer
#  is_flagged             :boolean
#  processing             :boolean          default(TRUE)
#
class Item < ApplicationRecord
  attr_accessor :agreement

  has_attached_file :image
  has_attached_file :meme_card

  has_many :sales, as: :nft_asset, dependent: :destroy

  validates :owner, presence: true, format: { with: /[0][x]\h{40}/, message: "must be a valid wallet address" }
  validates :agreement, acceptance: true

  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
  validates_attachment :image, presence: true, size: { less_than: 8.megabytes }

  validate :printer_is_live

  before_create :generate_uri, :run_validations, :generate_meme_card
  after_create  :run_after_create

  enum generation: {
      zero: 0,
      one:  1,
      two:  2,
      three: 3
  }

  attr_accessor :nonce, :signed_msg

  def generate_uri
    self.uri = SecureRandom.hex(16)
  end

  def printer_is_live
    return nil if ENV["PRINTER_IS_LIVE"] == "true"

    errors.add(:base, "Server is in test mode. Please use alternate test urls.")
    throw(:abort)
  end

  def generate_meme_card
    self.meme_card = generation_instance.new(item: self).generate_card
  end

  def run_validations
    generation_instance.new(item: self).run_validations
  end

  def run_after_create
    generation_instance.new(item: self).run_after_create
  end

  def generation_instance
    @generation_instance ||= "Generations::#{generation.classify}".constantize
  end

  def can_remint?
    generation == "one" && Sale.find_by(nft_asset: self).blank? && ENV["ALLOW_REMINT"] == "true"
  end

  def order_id
    "#{ENV["NP_LOCAL_POISON"]}ITEM_00_#{self.id}"
  end

  def ipfs_url
    "ipfs://#{ipfs_file_cid}"
  end
end
