apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
TweetStream.configure do |config|
  config.consumer_key       = apiconfig["twitter"]["consumer_key"]
  config.consumer_secret    = apiconfig["twitter"]["consumer_secret"]
  config.oauth_token        = apiconfig["twitter"]["access_token_key"]
  config.oauth_token_secret = apiconfig["twitter"]["access_token_secret"]
  config.auth_method        = :oauth
end

natto = Natto::MeCab.new(dicdir: ApplicationRecord::MECAB_NEOLOGD_DIC_PATH)

extra_info = ExtraInfo.read_extra_info

citore_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = apiconfig["twitter"]["consumer_key"]
  config.consumer_secret     = apiconfig["twitter"]["consumer_secret"]
  config.access_token        = extra_info["twitter_811029389575979008"]["token"]
  config.access_token_secret = extra_info["twitter_811029389575979008"]["token_secret"]
end

sugarcoat_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = apiconfig["twitter"]["consumer_key"]
  config.consumer_secret     = apiconfig["twitter"]["consumer_secret"]
  config.access_token        = extra_info["twitter_811024427487936512"]["token"]
  config.access_token_secret = extra_info["twitter_811024427487936512"]["token_secret"]
end

stream_client = TweetStream::Client.new
stream_client.track('#citore', '#Citore', '@citore_bot', '@sugarcoat_bot', '#sugarcoat', '#SugarCoat') do |status|
  next if status.lang != "ja" || ["811029389575979008", "811024427487936512"].include?(status.user.id.to_s)

  sanitaized_word = TwitterRecord.sanitized(status.text)
  without_url_tweet, urls = ApplicationRecord.separate_urls(sanitaized_word)
  reading = ApplicationRecord.reading(without_url_tweet)
  erotic_word = Citore::EroticWord.reading_words.detect{|r| reading.include?(r) }
  citore_client.update("@#{status.user.screen_name} テスト")
end