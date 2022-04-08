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
      im = Magick::Image.from_blob(image.download)
      im = im[0].resize_to_fit(531) # Template size
      im_template = Magick::Image.read("data/pics/card_template.jpg")

      x_coord = ((531 - im.columns.to_i) / 2) + 81
      y_coord = ((531 - im.rows.to_i) / 2) + 189
      im3 = im_template[0].composite(im,x_coord,y_coord, Magick::OverCompositeOp)

      gc = Magick::Draw.new
      gc.annotate(im3, 10, 10, 10, 10, '"Hello there!"')

      # title.annotate(montage, 0,0,0,40, 'Named Colors') {
      #   self.font_family = 'Helvetica'
      #   self.fill = 'white'
      #   self.stroke = 'transparent'
      #   self.pointsize = 32
      #   self.font_weight = BoldWeight
      #   self.gravity = NorthGravity
      # }

      t = Tempfile.new
      t.binmode
      t.write(im3.to_blob)
      t.rewind

      self.meme_card.attach(io: t, filename: "foo.jpg", content_type: "image/jpeg")
    end
  end
end
