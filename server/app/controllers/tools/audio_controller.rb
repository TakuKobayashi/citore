class Tools::AudioController < Homepage::BaseController
  before_action :check_and_auth_account, only: :listen_from_spotify

  def index
  end

  def listen_from_spotify
  end

  def crawl
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
      session["visitor_id"] = @visitor.id
      redirect_to "/auth/spotify" and return
    end
  end
end
