class TweetVoiceController < BaseController
  def search
    natto = Natto::MeCab.new
    words = []
    natto.parse(params[:text]) do |n|
      words << n.surface if n.surface.present?
    end
    seed = TweetSeed.where(search_keyword: TweetSeed::ERO_KOTOBA_BOT, tweet: words).sample
    t_voice = {}
    if params[:aegi].present?
      t_voice = TweetSeed.where(search_keyword: TweetSeed::AEGIGOE_BOT).sample.tweet_voices.sample
    else
      t_voice = seed.tweet_voices.sample
    end
    render :json => t_voice.to_json
  end

  def download
  	tweet_voice = TweetVoice.find_by(id: params[:tweet_voice_id])
  	filepath = TweetVoice.voice_file_root_path + tweet_voice.speech_file_path
    stat = File::stat(filepath)
    send_file(filepath, :filename => tweet_voice.speech_file_path, :length => stat.size)
  end
end
