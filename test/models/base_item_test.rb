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
require 'test_helper'

class BaseItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
