class Hackathon::Musichackday2018::Api::LocationController < Hackathon::Musichackday2018::Api::BaseController
  def notify
    last_location = @user.update_location!(lat: params[:lat].to_f, lon: params[:lon].to_f)
    locations = Hackathon::Musichackday2018::LastLocation.where.not(user_id: @user.id).within(0.5, origin: [last_location.lat, last_location.lon]).preload(:user)
    user_players = Hackathon::Musichackday2018::SoundPlayer.where(user_id: locations.map(&:user_id)).preload(log: :sound).index_by(&:user_id)
    render :layout => false, :json => {
      sender: {
        lat: params[:lat].to_f,
        lon: params[:lon].to_f
      },
      timestamp: Time.current.to_i,
      neighbours: locations.map do |location|
        player = user_players[location.user_id]
        {
          sound_url: player.try(:log).try(:sound).try(:file_url).to_s,
          distance: location.distance_to(last_location) * 1000,
          lat: location.lat,
          lon: location.lon,
          user_token: location.user.token,
          sound_name: player.try(:log).try(:sound).try(:title).to_s,
          artist_name: player.try(:log).try(:sound).try(:artist_name).to_s,
        }
        end
    }
  end
end
