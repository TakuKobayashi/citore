class Bannosama::PhotosController < Bannosama::BaseController
  def index
  end

  def upload
    upload_files = params[:image_files] || []
    render :json => {upload_file_count: upload_files.size}
  end
end
