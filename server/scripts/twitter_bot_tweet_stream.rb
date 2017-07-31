apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
TweetStream.configure do |config|
  config.consumer_key       = apiconfig["twitter"]["citore"]["consumer_key"]
  config.consumer_secret    = apiconfig["twitter"]["citore"]["consumer_secret"]
  config.oauth_token        = apiconfig["twitter"]["citore"]["bot"]["access_token_key"]
  config.oauth_token_secret = apiconfig["twitter"]["citore"]["bot"]["access_token_secret"]
  config.auth_method        = :oauth
end

natto = ApplicationRecord.get_natto

extra_info = ExtraInfo.read_extra_info

citore_client = TwitterRecord.get_twitter_rest_client("citore")

sugarcoat_client = TwitterRecord.get_twitter_rest_client("sugarcoat")

sugarcoat_keywords = ['@sugarcoat_bot', '#sugarcoat']
citore_keywords = ['#citore', '@citore_bot']

CacheStore.cache!
stream_client = TweetStream::Client.new
stream_client.track('#citore', '@citore_bot', '@sugarcoat_bot', '#sugarcoat') do |status|
  next if status.lang != "ja" || ["811029389575979008", "811024427487936512"].include?(status.user.id.to_s)

  sanitaized_word = TwitterRecord.sanitized(status.text)
  without_url_tweet, urls = ApplicationRecord.separate_urls(sanitaized_word)
  if citore_keywords.any?{|k| without_url_tweet.include?(k) }
    reading = ApplicationRecord.reading(without_url_tweet)
    erotic_word = Citore::EroticWord.reading_words.detect{|r| reading.include?(r) }
    citore_client.update("@#{status.user.screen_name} テスト")
  end
  if citore_keywords.any?{|k| without_url_tweet.include?(k) }
    reading = ApplicationRecord.reading(without_url_tweet)
    sugarcoat_client.update("@#{status.user.screen_name} テスト")
  end
end