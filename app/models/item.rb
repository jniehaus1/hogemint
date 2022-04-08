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
  has_attached_file :image
  has_attached_file :meme_card

  validates :owner, presence: true, format: { with: /[0][x]\h{40}/, message: "must be a valid wallet address" }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  validate :owner_matches_signed_msg
  validate :owner_is_unique
  validate :owner_has_hoge
  validate :meme_is_unique
  validate :printer_is_live

  before_create :generate_uri
  after_create  :generate_meme_card

  attr_accessor :nonce, :signed_msg

  # May be ethereum prefixed on production
  MSG_PREFIX = "We generated a token to prove that you're you! Sign with your account to protect your data. Unique Token: ".freeze

  def generate_uri
    self.uri = SecureRandom.hex(32)
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

    errors.add(:base, "Owner wallet must have containd HOGE tokens BEFORE WhiteBIT listing March 3rd, 2021.")
    throw(:abort)
  end

  def meme_is_unique
    image_hash = Digest::MD5.hexdigest(Paperclip.io_adapters.for(self.image).read)
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

  def printer_is_live
    return nil if ENV["PRINTER_IS_LIVE"] == "true"

    errors.add(:base, "Server is in test mode. Please use alternate test urls.")
    throw(:abort)
  end

  def generate_meme_card
    if image.present?
      Items::CardGenerator.call(self)
    end
  end
end
