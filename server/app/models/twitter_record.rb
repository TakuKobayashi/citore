class TwitterRecord < ApplicationRecord
  self.abstract_class = true

  ERO_KOTOBA_BOT = "ero_kotoba_bot"
  AEGIGOE_BOT = "aegigoe_bot"

  ERO_KOTOBA_KEY = "ero_kotoba"

  def self.generate!(text, keyword, twitter_info = {}, options = {})
    puts text
    reading = ApplicationRecord.reading(text)
    words = ngram(text, 2).uniq
    words.map do |key|
      tweet = TweetVoiceSeedDynamo.find(key: key, reading: reading,keyword: keyword)
      if tweet.blank?
        tweet = TweetVoiceSeedDynamo.new
        tweet.key = key
        tweet.reading = reading
        tweet.uuid = SecureRandom.hex
        tweet.keyword = keyword
      end
      tweet.appear_count = tweet.appear_count.to_i + 1
      if twitter_info.present?
        if tweet.twitter_info.blank?
          tweet.twitter_info = []
        end
        tweet.twitter_info += [twitter_info]
      end
      if options.present?
        tweet.options = options
      end
      tweet.save!
      tweet
    end
  end

  def self.sanitized(text)
    sanitized_word = ApplicationRecord.basic_sanitize(text)
    #返信やハッシュタグを除去
    sanitized_word = sanitized_word.gsub(/[#＃@][Ａ-Ｚａ-ｚA-Za-z一-鿆0-9０-９ぁ-ヶｦ-ﾟー_]+/, "")
    #リツイートにRTとつける事が多いので、そこの部分は取り除く
    sanitized_word = sanitized_word.gsub(/RT[;: ]/, "")
    
    # 余分な空欄を除去
    sanitized_word.strip!
    return sanitized_word
  end

  def self.generate_data_and_voice(keyword, text, twitter_info = {}, options = {})
    sanitaized_word = sanitized(text)
    puts sanitaized_word

    split_words = bracket_split(sanitaized_word)
    if split_words.blank?
      split_words = [sanitaized_word]
    end

    split_words.each do |word|
      generate!(word, keyword, twitter_info, options)
      puts "generate_voice"
      Citore::VoiceWord.all_speacker_names.each do |speacker|
        Citore::VoiceWord.generate_and_upload_voice(ApplicationRecord.reading(word), ERO_KOTOBA_KEY, speacker)
      end
    end
  end
end