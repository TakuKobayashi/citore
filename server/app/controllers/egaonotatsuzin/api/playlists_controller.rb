class Egaonotatsuzin::Api::PlaylistsController < Egaonotatsuzin::Api::BaseController
  def index
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    playlists = @user.spotify.import_and_load_playlists!
    render :layout => false, :json => {access_token: @user.spotify.token, client_id: apiconfig["apotify"]["client_id"], playlists: playlists}
  end

  def analysis
    analysis = @user.spotify.audio_analysis(track_id: params[:track_id])
    render :layout => false, :json => analysis
  end
end
