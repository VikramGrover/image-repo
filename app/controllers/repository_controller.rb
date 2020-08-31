class RepositoryController < ApplicationController
  require 'aws-sdk-s3'
  require 'dotenv'

  Dotenv.load

  def index
  end

  def upload
    new_image = Image.create(name: params[:image].original_filename, image_text: '', tags: '', s3_url: '')
    obj = @s3.bucket(Rails.application.credentials.aws[:bucket]).object(new_image.id.to_s)
    success = obj.upload_file(params[:image].tempfile.path)
    Image.delete(new_image.id) unless success

    Image.clear_selection

    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Success' }
      format.json { head :no_content }
    end

    response = @image_annotator.label_detection(
      image: params[:image].tempfile.path,
      max_results: 10
    )

    tags = ''
    response.responses.each do |res|
      res.label_annotations.each do |label|
        if label.score > 0.80
          tags += "|#{label.description}"
        end
      end
    end

    new_image.tags = tags
    new_image.save
  end

  def search
    images = []
    Image.all.each do |img|
      if img.tags.downcase().include?(params[:search].downcase())
        images << img
      end
    end

    Image.set_selection(images)

    respond_to do |format|
      format.html { redirect_to root_url + "repository/?search=#{params[:search]}", notice: 'Success' }
      format.json { head :no_content }
    end
  end

  def image_search
    response = @image_annotator.label_detection(
      image: params[:image].tempfile.path,
      max_results: 10
    )

    matches = []
    Image.all.each do |img|
      response.responses.each do |res|
        res.label_annotations.each do |label|
          tag = label.description.downcase()
          if img.tags.downcase().include?(tag)
            matches << img
            break
          end
        end
      end
    end

    Image.set_selection(matches)

    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Success' }
      format.json { head :no_content }
    end
  end
end
