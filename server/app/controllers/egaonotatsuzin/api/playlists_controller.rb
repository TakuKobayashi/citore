class Egaonotatsuzin::Api::PlaylistsController < Egaonotatsuzin::Api::BaseController
  def index
    playlists = @user.spotify.import_and_load_playlists!
    render :layout => false, :json => {access_token: @user.spotify.token, client_id: ENV.fetch('SPOTIFY_CLIENT_ID', ''), playlists: playlists}
  end

  def analysis
    analysis = @user.spotify.audio_analysis(track_id: params[:track_id])
    render :layout => false, :json => analysis
  end
end
