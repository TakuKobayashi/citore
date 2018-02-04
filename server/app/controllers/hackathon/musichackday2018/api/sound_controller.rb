class Hackathon::Musichackday2018::Api::SoundController < Hackathon::Musichackday2018::Api::BaseController
  def search_one
    keyword = params[:keyword]
    audio_meta = Datapool::YoutubeAudioMetum.search_and_import!(keyword: keyword)
    json_hash_arr = audio_meta[0..9].map do |metum|
      {
        sound_url: metum.src,
        sound_id: metum.id,
        sound_name: metum.title,
        artist_name: metum.artist_name,
        sound_image_url: metum.thumbnail_image_url
      }
    end
    render :layout => false, :json => {
      results: json_hash_arr
    }
  end

  def play
    sound = Datapool::YoutubeAudioMetum.find_by(id: params[:sound_id])
    sound_player = @user.setup_sound_player!(audio_metum: sound)
    render :layout => false, :json => {
      sound_file_url: sound_player.log.sound.file_url,
      sound_player_log_id: sound_player.log_id,
      sound_duration: sound_player.sound_duration
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
