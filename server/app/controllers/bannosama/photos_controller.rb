class Bannosama::PhotosController < Bannosama::BaseController
  protect_from_forgery

  def index
  end

  def upload
    audio_file = params[:audio_file]
    greet = Bannosama::Greet.new(from_user_id: @user.id, message: params[:say_comment].to_s, theme: params[:theme].to_i)
    greet.upload_s3_and_set_audiofile(audio_file)
    greet.save!

    upload_files = params[:image_files] || []

    images = []
    upload_files.each do |image_file|
      greet_image = greet.images.new
      greet_image.upload_s3_and_set_metadata(image_file)
      images << greet_image
    end
    Bannosama::GreetImage.import(images)

    greet.generate_thumnail!(upload_files.first)

    hash = params.dup.delete_if{|k, v| ["controller", "action", "image_files", "audio_file"].include?(k) }
    render :json => {upload_file_count: upload_files.size, params: hash}
  end
end
