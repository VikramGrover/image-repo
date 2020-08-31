class ApplicationController < ActionController::Base
  require 'google/cloud/vision'

  before_action :set_variables

  Dotenv.load

  def set_variables
    @s3 = Aws::S3::Resource.new(region: Rails.application.credentials.aws[:region], access_key_id: Rails.application.credentials.aws[:access_key_id],
                                secret_access_key: Rails.application.credentials.aws[:secret_access_key])
    @image_annotator = Google::Cloud::Vision.image_annotator
  end
end
