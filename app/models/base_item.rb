# == Schema Information
#
# Table name: base_items
#
#  id                 :bigint           not null, primary key
#  uri                :string
#  owner              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :bigint
#  image_updated_at   :datetime
#
class BaseItem < ApplicationRecord
  has_attached_file :image

  has_many :sales, as: :nft_asset

  validates :owner, presence: true, format: { with: /[0][x]\h{40}/, message: "must be a valid wallet address" }

  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
  validates_attachment_size :image, :less_than => 5.megabytes, :unless => Proc.new { |m| m[:image].nil? }

  before_create :generate_uri

  def generate_uri
    self.uri = SecureRandom.hex(16)
  end

  def order_id
    "BASEITEM_TWO_#{self.id}"
  end

  def generation
    ENV["CURRENT_GENERATION"]
  end
end
