class Citore::VoiceController < BaseController
  def search
    natto = Natto::MeCab.new
    sanitaized_word = TweetVoiceSeedDynamo.sanitized(params[:text].to_s)
    reading = TweetVoiceSeedDynamo.reading(sanitaized_word)
    split_words = TweetVoiceSeedDynamo.ngram(reading, 2).uniq

    results = []
    split_words.each do |word|
      results = TweetVoiceSeedDynamo.query({
        key_condition_expression: "#H = :h AND #K = :k",
        filter_expression: "contains(#B, :b)",
        expression_attribute_names: {"#H" => "key", "#B" => "reading", "#K" => "keyword"},
        expression_attribute_values: {":h" => word, ":b" => word, ":k" => TweetVoiceSeedDynamo::ERO_KOTOBA_KEY }
      }).map{|r| r }.select{|r| reading.include?(r.reading) }
      break if results.present?
    end

    result = results.sample
    render :json => {} and return if result.blank?
    hash = {uuid: result.try(:uuid), reading: result.try(:reading), key: result.try(:key) }) || {}
    voice = VoiceDynamo.find(word: result.try(:reading), speaker_name: Voice.all_speacker_names.sample)
    filename = File.basename(voice.file_name.to_s)
    if filename.present?
      hash.merge!(file_name: filename, speaker_name: voice.speaker_name)
    end
    render :json => hash
  end

  def download
    tweet = TweetVoiceSeedDynamo.find(key: params[:key], reading: params[:reading], uuid: params[:uuid])
    voice = VoiceDynamo.find(word: tweet.reading, speaker_name: params[:speaker_name].to_s)

    filepath = VoiceDynamo::VOICE_S3_FILE_ROOT + voice.file_name.to_s

    s3 = Aws::S3::Client.new
    filename = File.basename(filepath)
    ext = File.extname(filename)
    resp = s3.get_object({bucket: "taptappun", key: filepath})
    send_data(resp.body.read,{filename: filename, type: "audio/" + ext[1..(ext.size - 1)]})
  end
end
