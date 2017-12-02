class Hackathon::Sunflower::ImagesController < BaseController
  def index
  end

  def upload_ferry
    upload_files = params[:image_files] || []
    render :json => {upload_file_count: upload_files.size, params: params.keys}
  end

  def upload_target
    upload_file = params[:target_image]
    render :json => {upload_file_name: upload_file.original_filename, params: params.keys}
  end

  def upload_image_resources
    upload_files = params[:image_files] || []
    render :json => {upload_file_count: upload_files.size, params: params.keys}
  end
end
