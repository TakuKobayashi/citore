apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
TweetStream.configure do |config|
  config.consumer_key       = apiconfig["twitter"]["fey_kun_ai"]["consumer_key"]
  config.consumer_secret    = apiconfig["twitter"]["fey_kun_ai"]["consumer_secret"]
  config.oauth_token        = apiconfig["twitter"]["fey_kun_ai"]["bot"]["access_token_key"]
  config.oauth_token_secret = apiconfig["twitter"]["fey_kun_ai"]["bot"]["access_token_secret"]
  config.auth_method        = :oauth
end

natto = ApplicationRecord.get_natto

stream_client = TweetStream::Client.new
stream_client.userstream do |status|
#  p status.to_h
  if status.in_reply_to_screen_name == "fey_kun_ai" && status.user.screen_name != "fey_kun_ai"
    inquiry_tweet = FeyKunAi::InquiryTweet.generate_tweet!(tweet: status)
    inquiry_tweet.check_and_request_analize
  end
end