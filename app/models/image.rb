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
class Image < ApplicationRecord
end
