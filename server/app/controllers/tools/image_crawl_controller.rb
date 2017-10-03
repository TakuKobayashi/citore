class Tools::ImageCrawlController < Homepage::BaseController
  before_action :load_upload_jobs, only: [:index, :url, :twitter, :flickr]
  before_action :execute_upload_job, only: [:url_crawl, :twitter_crawl, :flickr_crawl]

  def index
  end

  def twitter
  end

  def twitter_crawl
    render :json => @upload_job.to_json
  end

  def flickr
  end

  def flickr_crawl
    render :json => @upload_job.to_json
  end

  def url
  end

  def url_crawl
    render :json => @upload_job.to_json
  end

  private
  def load_upload_jobs
    @upload_jobs = @visitor.try(:upload_jobs) || []
  end

  def execute_upload_job
    @upload_job = @visitor.upload_jobs.new(token: params[:authenticity_token])
    if params[:action] == "flickr_crawl"
      @upload_job.from_type = "Datapool::FrickrImageMetum"
    elsif params[:action] == "twitter_crawl"
      @upload_job.from_type = "Datapool::TwitterImageMetum"
    else
      @upload_job.from_type = "Datapool::WebSiteImageMetum"
    end
    @upload_job.save!
    ImageCrawlJob.perform_later(params.to_h.dup, @upload_job)
  end
end