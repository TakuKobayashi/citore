class Hackathon::Musichackday2018::Api::SoundController < Hackathon::Musichackday2018::Api::BaseController
  def search_one
    keyword = params[:keyword]
    play_sound_log = @user.setup_sound_player!(keyword: keyword)
    render :layout => false, :json => {
      sound_url: "https://maoudamashii.jokersounds.com/music/bgm/mp3/bgm_maoudamashii_orchestra26.mp3",
      sound_id: play_sound_log.id,
      sound_name: "hogehoge",
      artist_name: "氷川きよし",
      sound_image_url: "https://pics.prcm.jp/9902f9f4d3c80/65452637/png/65452637.png"
    }
  end

  def play
    sound_player = @user.sound_player
    sound_player.play!
    render :layout => false, :json => {
      sound_id: sound_player.log_id,
      sound_duration: 100.to_f
    }
  end

  def play_next
    render :layout => false, :json => {
      before_id: params[:sound_id].to_i,
      sound_url: "https://maoudamashii.jokersounds.com/music/bgm/mp3/bgm_maoudamashii_orchestra26.mp3",
      sound_id: 1,
      sound_name: "hogehoge",
      artist_name: "氷川きよし",
      sound_image_url: "https://pics.prcm.jp/9902f9f4d3c80/65452637/png/65452637.png"
    }
  end

  def keep_remix
    render :layout => false, :json => {
      base_sound_id: params[:sound_id].to_i,
      neighbour_sound_id: params[:neighbour_sound_id].to_i,
      neighbour_user_token: params[:neighbour_user_token].to_s
    }
  end
end
