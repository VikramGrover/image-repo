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
  @currently_selected = Image.all

  def self.clear_selection
    @currently_selected = Image.all
  end

  def self.set_selection(images)
    @currently_selected = images
  end

  def self.get_selection
    @currently_selected
  end
end
