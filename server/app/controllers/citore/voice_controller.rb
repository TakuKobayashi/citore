class Citore::VoiceController < BaseController
  def search
    natto = Natto::MeCab.new
    sanitaized_word = TweetVoiceSeedDynamo.sanitized(params[:text].to_s)
    reading = TweetVoiceSeedDynamo.reading(sanitaized_word)
    split_words = TweetVoiceSeedDynamo.ngram(reading, 2).uniq

    results = []
    natto.parse(sanitaized_word) do |n|
      next if n.surface.blank?
      csv = n.feature.split(",")
      next if !csv[0].to_s.include?("動詞") && csv[0].to_s.include?("名詞")
      split_words.each do |word|
        results = TweetVoiceSeedDynamo.query({
          key_condition_expression: "#H = :h",
          filter_expression: "contains(#B, :b)",
          expression_attribute_names: {"#H" => "key", "#B" => "reading"},
          expression_attribute_values: {":h" => n.surface, ":b" => word}
        }).map{|r| r }
        break if results.present?
      end
      break if results.present?
    end

    result = results.sample
    render :json => {} and return if result.blank?
    hash = {key: result.try(:key), reading: result.try(:reading)}.merge(result.try(:info)) || {}
    voice = VoiceDynamo.find(word: result.try(:reading), speaker_name: Voice.all_speacker_names.sample)
    filename = File.basename(voice.info["file_path"].to_s)
    render :json => hash.merge(file_name: filename)
  end

  def download
    tweet = TweetVoiceSeedDynamo.find(key: params[:key], reading: params[:reading])
    speaker = Voice.all_speacker_names.detect{|n| params[:file_name].to_s.include?(n) }
    voice = VoiceDynamo.find(word: tweet.reading, speaker_name: speaker)

    filepath = voice.info["file_path"].to_s

    s3 = Aws::S3::Client.new
    filename = File.basename(filepath)
    ext = File.extname(filename)
    resp = s3.get_object({bucket: "taptappun", key: filepath})
    send_data(resp.body.read,{filename: filename, type: "audio/" + ext[1..(ext.size - 1)]})
  end
end
