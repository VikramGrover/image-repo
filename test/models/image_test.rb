# == Schema Information
#
# Table name: images
#
#  id         :bigint           not null, primary key
#  name       :string
#  image_text :text
#  tags       :text
#  s3_url     :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
