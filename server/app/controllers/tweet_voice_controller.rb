class TweetVoiceController < BaseController
  def search
    natto = Natto::MeCab.new
    words = []
    natto.parse(params[:text]) do |n|
      words << n.surface if n.surface.present?
    end
    seed = TweetSeed.where(search_keyword: TweetSeed::ERO_KOTOBA_BOT, tweet: words).where("id <= 839").sample
    if params[:aegi].present?
      t_voice = TweetSeed.where(search_keyword: TweetSeed::AEGIGOE_BOT).sample.tweet_voices.sample
    else
      t_voice = seed.tweet_voices.sample
    end
    t_voice ||= {}
    render :json => t_voice.to_json
  end

  def download
  	tweet_voice = TweetVoice.find_by(id: params[:tweet_voice_id])
  	filepath = TweetVoice.voice_file_root_path + tweet_voice.speech_file_path
    stat = File::stat(filepath)

    s3 = Aws::S3::Client.new
    filename = File.basename(filepath)
    ext = File.extname(filename)
    resp = s3.get_object({bucket: "taptappun", key: file_name})
    send_data(resp.body.read, filename: filename type: "audio/" + ext[1..(ext.size - 1)])
    #send_file(filepath, :filename => tweet_voice.speech_file_path, :length => stat.size)
  end
end
