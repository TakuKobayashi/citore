class TwitterRecord < ApplicationRecord
  self.abstract_class = true

  CRAWL_STATES = {
    pending: 0,
    crawling: 1,
    stay: 2,
    completed: 3
  }

  CRAWL_RESET_TIME_SPAN = 12.hours

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

  def self.generate_data_and_voice!(text:, twitter_word_id: nil, generate_voice: false)
    sanitaized_word = TwitterRecord.sanitized(text)
    puts sanitaized_word

    split_words = ApplicationRecord.bracket_split(sanitaized_word)
    if split_words.blank?
      split_words = [sanitaized_word]
    end

    transaction do
      split_words.each do |word|
        twitter_record = try(:generate!, word, twitter_word_id)
        puts "generate_voice"
        if generate_voice
          VoiceWord.all_speacker_names.each do |speacker|
            VoiceWord.generate_and_upload_voice!(twitter_record, ApplicationRecord.reading(word), speacker)
          end
        end
      end
    end
  end

  def self.get_tweets(*twitter_ids)
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    client = self.get_twitter_rest_client("citore")
    tweets = client.statuses(twitter_ids)
    return tweets
  end

  def self.twitter_crawl(prefix_key: "", crawl_options: {})
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    client = self.get_twitter_rest_client("citore")
    is_all = false
    start_time = Time.now
    limit_span = (15.minutes.second / 180).to_i

    extra_info = ExtraInfo.read_extra_info
    crawl_info = extra_info[prefix_key + self.table_name] || {}
    state = crawl_info["state"].to_i
    return if !["pending", "completed"].include?(CRAWL_STATES.invert[state].to_s)

    last_tweet_id = crawl_info["last_tweet_id"]
    if crawl_info["complete_time"].present? && Time.parse(crawl_info["complete_time"]) < CRAWL_RESET_TIME_SPAN.ago 
      last_tweet_id = nil
    end
    crawl_info["start_time"] = Time.now
    while is_all == false do
      crawl_info["state"] = CRAWL_STATES[:crawling]
      puts crawl_info
      ExtraInfo.update({self.table_name => crawl_info})
      sleep limit_span
      options = crawl_options.merge({:count => 100})
      if last_tweet_id.present?
        options[:max_id] = last_tweet_id.to_i
      end
      puts options
      tweet_results = yield(client, options)
      is_all = tweet_results.size < 100
      last_tweet_id = tweet_results.select{|s| s.try(:id).present? }.min_by{|s| s.id.to_i }.try(:id).to_i
      crawl_info["last_tweet_id"] = last_tweet_id
      crawl_info["state"] = CRAWL_STATES[:stay]
      ExtraInfo.update({(prefix_key + self.table_name) => crawl_info})
    end
    crawl_info["state"] = CRAWL_STATES[:completed]
    crawl_info["complete_time"] = Time.now
    ExtraInfo.update({self.table_name => crawl_info})
  end

  def self.get_image_urls_from_tweet(tweet:)
    image_urls = tweet.media.flat_map do |m|
      case m
      when Twitter::Media::Photo
        m.media_url.to_s
      when Twitter::Media::Video
        m.media_url.to_s
      else
        []
      end
    end
    return image_urls
  end

  def self.get_video_urls_from_tweet(tweet:)
    video_urls = tweet.media.flat_map do |m|
      case m
      when Twitter::Media::Video
        max_bitrate_variant = m.video_info.variants.max_by{|variant| variant.bitrate.to_i }
        [max_bitrate_variant.try(:url)].compact
      else
        []
      end
    end
    return video_urls
  end

  def self.get_twitter_rest_client(username)
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    rest_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = apiconfig["twitter"][username]["consumer_key"]
      config.consumer_secret     = apiconfig["twitter"][username]["consumer_secret"]
      config.access_token        = apiconfig["twitter"][username]["bot"]["access_token_key"]
      config.access_token_secret = apiconfig["twitter"][username]["bot"]["access_token_secret"]
    end
    return rest_client
  end

  def self.get_twitter_stream_client(username)
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    stream_client = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = apiconfig["twitter"][username]["consumer_key"]
      config.consumer_secret     = apiconfig["twitter"][username]["consumer_secret"]
      config.access_token        = apiconfig["twitter"][username]["bot"]["access_token_key"]
      config.access_token_secret = apiconfig["twitter"][username]["bot"]["access_token_secret"]
    end
    return stream_client
  end
end
