class Homepage::Tools::VideoController < Homepage::BaseController
  def index
  end

  def editor
  end

  def edit
    video_url = params[:video_url]
    video_file = params[:video_file]
    upload_url = params[:upload_url]
  end

  def crawl
  end

  def execute_crawl
    redirect_to crawl_tools_video_url
  end
end