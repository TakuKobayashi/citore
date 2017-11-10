class Tools::AudioController < Homepage::BaseController
  before_action :check_and_auth_account, only: :listen_from_spotify
  before_action :execute_upload_job, only: :execute_crawl

  def index
  end

  def listen_from_spotify
  end

  def crawl
    if @visitor.blank?
      @upload_jobs = []
    else
      @upload_jobs = @visitor.upload_jobs.where.not(state: :cleaned).where(from_type: "Datapool::WebSiteAudioMetum").order("id DESC")
    end
  end

  def crawl_website
  end

  def execute_crawl
    redirect_to crawl_tools_audio_url
  end

  private
  def check_and_auth_account
    if @visitor.spotify.nil?
      session["redirect_url"] = listen_from_spotify_tools_audio_url
      session["user_id"] = @visitor.id
      session["user_type"] = @visitor.class.to_s
      redirect_to "/auth/spotify" and return
    end
  end

  def execute_upload_job
    if params["crawl_type"] == "website"
      prefix = "Datapool::WebSiteAudioMetum"
    else
      prefix = ""
    end
    @upload_job = @visitor.upload_jobs.find_or_initialize_by(token: params[:authenticity_token])
    @upload_job.from_type = prefix
    @upload_job.options ||= {params: params.to_h.dup}
    @upload_job.save!
    flash[:notice] = "処理を受け付けました。処理が完了するまでしばらくお待ち下さい。"
    AudioCrawlWorker.perform_async(params.to_h.dup, @upload_job.id)
  end
end
