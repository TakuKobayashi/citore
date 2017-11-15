class Egaonotatsuzin::Api::PlaylistsController < Egaonotatsuzin::BaseController
  def index
    playlists = @user.spotify.get_playlists
    render :layout => false, :json => playlists
  end

  def analysis
    analysis = @user.spotify.audio_analysis(track_id: params[:track_id])
    render :layout => false, :json => analysis
  end

  def config
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    render :layout => false, :json => {access_token: @user.spotify.token, client_id: apiconfig["apotify"]["client_id"]}
  end
end
