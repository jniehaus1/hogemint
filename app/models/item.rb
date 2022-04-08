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
  has_one_attached :meme_card

  # validates :owner, presence: true, format: { with: /[0][x]\h{40}/, message: "Must be a valid wallet address" }
  validates :image, presence: true, blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg'], size_range: 0..5.megabytes }
  validate :owner_is_unique
  # validate :owner_has_hoge

  before_create :generate_uri
  after_create  :generate_meme_card

  attr_accessor :nonce, :signed_msg

  def generate_uri
    # stuff
  end

  def owner_is_unique
    return nil unless Item.find_by(owner: owner).present?

    errors.add(:owner, "Wallet address must be unique. It has already been used!")
    throw(:abort)
  end

  def owner_has_hoge
    return nil unless HOGE_HOLDERS.include?(item_params[:owner].hex)

    errors.add(:owner, "Wallet address must contain HOGE tokens.")
    throw(:abort)
  end

  def key_owner
    Eth::Utils.public_key_to_address(key_from_msg)
  end

  def key_from_msg
    Eth::Key.personal_recover(MSG_PREFIX + item_params[:nonce], item_params[:signed_msg])
  end

  def generate_meme_card
    if image.attached?
      im = Magick::Image.from_blob(image.download)
      im = im[0].resize_to_fit(531) # Template size
      im_template = Magick::Image.read("data/card_template.jpg")

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
