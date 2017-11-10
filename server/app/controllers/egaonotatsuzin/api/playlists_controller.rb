class Egaonotatsuzin::Api::PlaylistsController < Egaonotatsuzin::BaseController
  def index
    playlists = @user.spotify.get_playlists
    render :layout => false, :json => playlists
  end

  def analysis
    analysis = @user.spotify.audio_analysis(track_id: params[:track_id])
    render :layout => false, :json => analysis
  end
end
