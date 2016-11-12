apiconfig = YAML.load(File.open("config/apiconfig.yml"))
TweetStream.configure do |config|
  config.consumer_key       = apiconfig["twitter"]["consumer_key"]
  config.consumer_secret    = apiconfig["twitter"]["consumer_secret"]
  config.oauth_token        = apiconfig["twitter"]["access_token_key"]
  config.oauth_token_secret = apiconfig["twitter"]["access_token_secret"]
  config.auth_method        = :oauth
end

client = TweetStream::Client.new

client.track('エロく聞こえる言葉') do |status|
  puts "#{status.user.screen_name}: #{status.text}"
end