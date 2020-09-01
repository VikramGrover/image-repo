class RepositoryController < ApplicationController
  require 'aws-sdk-s3'
  require 'dotenv'
  require 'open-uri'

  Dotenv.load

  def index
  end

  def upload
    if params[:image]
      new_image = Image.create(name: params[:image].original_filename, image_text: '', tags: '', s3_url: '')
      obj = @s3.bucket(Rails.application.credentials.aws[:bucket]).object(new_image.id.to_s)
      success = obj.upload_file(params[:image].tempfile.path)

      unless success
        Image.delete(new_image.id)
        return
      end

      Image.reset_selection
      Image.set_status("Successfully uploaded '#{params[:image].original_filename}'")

      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end

      label_detection_response = @image_annotator.label_detection(
        image: params[:image].tempfile.path,
        max_results: 10
      )

      ocr_response = @image_annotator.document_text_detection(
        image: params[:image].tempfile.path
      )

      tags = ''
      label_detection_response.responses.each do |res|
        res.label_annotations.each do |label|
          if label.score > 0.80
            tags += "|#{label.description}"
          end
        end
      end

      text = ''
      ocr_response.responses.each do |res|
        res.text_annotations.each do |annotation|
          text << annotation.description
        end
      end

      new_image.tags = tags.downcase
      new_image.image_text = text.downcase
      new_image.save
    end
  end

  def search
    matching_images = []
    Image.all.each do |img|
      search_term = params[:search].downcase
      matching_images << img if img.tags.include?(search_term) || img.image_text.include?(search_term)
    end

    Image.set_selection(matching_images)
    Image.set_status("Search results for '#{params[:search]}'")

    respond_to do |format|
      format.html { redirect_to root_url + "repository/?search=#{params[:search]}" }
      format.json { head :no_content }
    end
  end

  def image_search
    label_detection_response = @image_annotator.label_detection(
      image: params[:image].tempfile.path,
      max_results: 10
    )

    matches = []
    Image.all.each do |img|
      label_detection_response.responses.each do |res|
        res.label_annotations.each do |label|
          tag = label.description.downcase()
          if img.tags.include?(tag)
            matches << img
            break
          end
        end
      end
    end

    Image.set_selection(matches)
    Image.set_status("Displaying similar images to '#{params[:image].original_filename}'")

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  def clear_search
    Image.reset_selection
    Image.set_status('')

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  def delete
    status = ''
    if params[:id] == '-1'
      Image.delete_all
      bucket = @s3.bucket(Rails.application.credentials.aws[:bucket])
      bucket.clear!
      status = 'Deleted all images'
    else
      status = "Deleted image '#{Image.find(params[:id]).name}'"
      Image.delete(params[:id])
      obj = @s3.bucket(Rails.application.credentials.aws[:bucket]).object(params[:id])
      obj.delete
    end

    Image.reset_selection
    Image.set_status(status)

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  def download
    file_name = Image.find(params[:id]).name
    @s3.bucket(Rails.application.credentials.aws[:bucket]).object(params[:id])
       .get(response_target: ENV['DOWNLOAD_PATH'] + file_name)

    Image.set_status("Downloaded image '#{file_name}' to downloads folder")

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end
end
