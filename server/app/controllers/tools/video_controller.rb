class Tools::VideoController < Homepage::BaseController
  def index
  end

  def editor
  end

  def edit
    video_url = params[:video_url]
    video_file = params[:video_file]
  end

  def crawl
  end

  def execute_crawl
    redirect_to crawl_tools_video_url
  end
end