class Hackathon::Musichackday2018::Api::LocationController < Hackathon::Musichackday2018::Api::BaseController
  def notify
    render :layout => false, :json => {
      sender: {
        lat: params[:lat],
        lon: params[:lon]
      },
      timestamp: Time.current.to_i,
      neighbours: [{
        sound_url: "https://maoudamashii.jokersounds.com/music/bgm/mp3/bgm_maoudamashii_orchestra26.mp3",
        distance: 100.0,
        lat: 35.6598891,
        lon: 139.7054377,
        user_token: "aaaa",
        sound_name: "hogehoge",
        artist_name: "氷川きよし",
      }]
    }
  end
end
