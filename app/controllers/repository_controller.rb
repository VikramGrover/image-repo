class RepositoryController < ApplicationController
  require 'aws-sdk-s3'
  require 'dotenv'

  Dotenv.load

  def index
  end

  def upload()
    newImage = Image.create(name: params[:image].original_filename, image_text: '', tags: '', s3_url: '')
    s3 = Aws::S3::Resource.new(region: 'us-east-1', access_key_id: Rails.application.credentials.aws[:access_key_id],
                               secret_access_key: Rails.application.credentials.aws[:secret_access_key])
    obj = s3.bucket(ENV['S3_BUCKET']).object(newImage.id.to_s)
    path = params[:image].tempfile.path
    result = obj.upload_file(path)
    puts result
  end
end
