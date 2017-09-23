class Bannosama::PhotosController < Bannosama::BaseController
  protect_from_forgery

  def index
  end

  def upload
    upload_files = params[:image_files] || []
    hash = params.dup.delete_if{|k, v| ["controller", "action"].include?(k) }
    render :json => {upload_file_count: upload_files.size, params: hash}
  end
end
