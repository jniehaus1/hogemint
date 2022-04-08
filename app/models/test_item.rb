# == Schema Information
#
# Table name: test_items
#
#  id          :bigint           not null, primary key
#  token_id    :integer
#  uri         :string
#  owner       :string
#  image_hash  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  flavor_text :string
#  title       :string
#
class TestItem < ApplicationRecord
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

  def generate_uri
    self.uri = SecureRandom.uuid
  end

  def owner_matches_signed_msg
    return nil if key_owner == owner

    errors.add(:base, "Owner does not match signed message. Did you use the correct wallet?")
  end

  def owner_is_unique
    true
  end

  def owner_has_hoge
    return nil if HOGE_HOLDERS.include?(owner.hex)

    errors.add(:base, "Owner wallet must contain HOGE tokens.")
    throw(:abort)
  end

  def meme_is_unique
    true
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
    true
  end


  def generate_meme_card
    if image.attached?
      Items::CardGenerator.call(self)
    end
  end
end
