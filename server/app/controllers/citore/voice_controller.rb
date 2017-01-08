class Citore::VoiceController < BaseController
  def search
    natto = Natto::MeCab.new(dicdir: ApplicationRecord::MECAB_NEOLOGD_DIC_PATH)
    sanitaized_word = ApplicationRecord.basic_sanitize(params[:text].to_s)
    reading = ApplicationRecord.reading(sanitaized_word)
    split_words = ApplicationRecord.ngram(reading, 2).uniq

    results = []
    split_words.each do |word|
      results = TweetVoiceSeedDynamo.query({
        key_condition_expression: "#H = :h AND #K = :k",
        filter_expression: "contains(#B, :b)",
        expression_attribute_names: {"#H" => "key", "#B" => "reading", "#K" => "keyword"},
        expression_attribute_values: {":h" => word, ":b" => word, ":k" => Citore::EroticWord::ERO_KOTOBA_KEY }
      }).map{|r| r }.select{|r| reading.include?(r.reading) }
      break if results.present?
    end

    result = results.sample
    render :json => {} and return if result.blank?
    hash = {uuid: result.try(:uuid), reading: result.try(:reading), key: result.try(:key) } || {}
    voice = VoiceDynamo.find(word: result.try(:reading), speaker_name: Voice.all_speacker_names.sample)
    filename = File.basename(voice.file_name.to_s)
    if filename.present?
      hash.merge!(file_name: filename, speaker_name: voice.speaker_name)
    end
    render :json => hash
  end

  def download
    erotic_word = Citore::EroticWord.find_by_used_cache(id: params[:word_id].to_i)
    voice = erotic_word.voices.find_by(speaker_name: params[:speaker_name])
    if voice.present?
      s3 = Aws::S3::Client.new
      origin_filename = File.basename(voice.file_name)
      ext = File.extname(origin_filename)
      resp = s3.get_object({bucket: "taptappun", key: voice.file_name})
      send_data(resp.body.read,{filename: origin_filename, type: "audio/" + ext[1..(ext.size - 1)]})
    else
      head(:ok)
    end
  end
end
