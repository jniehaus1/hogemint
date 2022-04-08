# == Schema Information
#
# Table name: items
#
#  id          :bigint           not null, primary key
#  token_id    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  uri         :string
#  owner       :string
#  image_hash  :string
#  flavor_text :string
#  title       :string
#
class Item < ApplicationRecord
  has_one_attached :image
  has_one_attached :meme_card

  validates :owner, presence: true, format: { with: /[0][x]\h{40}/, message: "must be a valid wallet address" }
  validates :image, presence: true, blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg'], size_range: 0..5.megabytes }
  validate :owner_matches_signed_msg
  validate :owner_is_unique
  validate :owner_has_hoge
  validate :meme_is_unique
  validate :printer_is_live

  before_create :generate_uri
  before_create :attach_image_hash
  after_create  :generate_meme_card

  attr_accessor :nonce, :signed_msg

  # May be ethereum prefixed on production
  MSG_PREFIX = "We generated a token to prove that you're you! Sign with your account to protect your data. Unique Token: ".freeze

  class << self
    def find_by_uri(uri: uri)
      Item.find_by(uri: uri)
    end
  end

  def generate_uri
    self.uri = SecureRandom.uuid
  end

  def owner_matches_signed_msg
    return nil if key_owner == owner

    errors.add(:base, "Owner does not match signed message. Did you use the correct wallet?")
  end

  def owner_is_unique
    return nil unless Item.find_by(owner: owner).present?

    errors.add(:base, "Owner address has already been used!")
    throw(:abort)
  end

  def owner_has_hoge
    return nil if HOGE_HOLDERS.include?(owner.hex)

    errors.add(:base, "Owner wallet must contain HOGE tokens.")
    throw(:abort)
  end

  def meme_is_unique
    image_hash = Digest::MD5.hexdigest(self.image.download)
    return nil unless Item.find_by(image_hash: image_hash).present?

    errors.add(:base, "Image has already been turned into a meme! Your image must be unique.")
    throw(:abort)
  end

  def key_owner
    # Assert validations
    Eth::Utils.public_key_to_address(key_from_msg)
  end

  def key_from_msg
    # Assert validations
    Eth::Key.personal_recover(MSG_PREFIX + nonce, signed_msg)
  end

  def attach_image_hash
    self.image_hash = Digest::MD5.hexdigest(self.image.download)
  end

  def printer_is_live
    return nil if ENV["PRINTER_IS_LIVE"] == "true"

    errors.add(:base, "Server is in test mode. Please use alternate test urls.")
    throw(:abort)
  end

  def generate_meme_card
    if image.attached?
      Items::CardGenerator.call(self)
    end
  end
end
