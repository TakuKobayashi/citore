class Bannosama::PhotosController < Bannosama::BaseController
  protect_from_forgery

  def index
  end

  def upload
    upload_files = params[:image_files] || []
    render :json => {upload_file_count: upload_files.size}
  end

  def upload_message
    render :json => params
  end
end
