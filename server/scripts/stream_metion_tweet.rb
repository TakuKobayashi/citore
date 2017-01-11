apiconfig = YAML.load(File.open("config/apiconfig.yml"))
TweetStream.configure do |config|
  config.consumer_key       = apiconfig["twitter"]["consumer_key"]
  config.consumer_secret    = apiconfig["twitter"]["consumer_secret"]
  config.oauth_token        = apiconfig["twitter"]["access_token_key"]
  config.oauth_token_secret = apiconfig["twitter"]["access_token_secret"]
  config.auth_method        = :oauth
end

client = TweetStream::Client.new
client.sample do |status|
  next if status.lang != "ja" || !status.in_reply_to_status_id?
  sanitaized_word = TwitterRecord.sanitized(status.text)
  without_url_tweet, urls = ApplicationRecord.separate_urls(sanitaized_word)

  puts status.in_reply_to_status_id
  TwitterWordMention.create!(
    twitter_user_id: status.user.id.to_s,
    twitter_user_name: status.user.screen_name.to_s,
    twitter_tweet_id: status.id.to_s,
    tweet: without_url_tweet,
    csv_url: urls.join(","),
    tweet_created_at: status.created_at,
    reply_to_tweet_id: status.in_reply_to_status_id.to_s
  )
end