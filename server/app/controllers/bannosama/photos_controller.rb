class Bannosama::PhotosController < Bannosama::BaseController
  protect_from_forgery

  def index
  end

  def upload
    greet = Bannosama::Greet.create(message: params[:say_comment].to_s, theme: params[:theme].to_i)
    upload_files = params[:image_files] || []
    images = []
    upload_files.each do |image_file|
      greet_image = greet.images.new
      greet_image.upload_s3_and_set_metadata(image_file)
      images << greet_image
    end
    Bannosama::GreetImage.import(images)

    greet.generate_thumnail!(upload_files.first)

    hash = params.dup.delete_if{|k, v| ["controller", "action"].include?(k) }
    render :json => {upload_file_count: upload_files.size, params: hash}
  end
end
