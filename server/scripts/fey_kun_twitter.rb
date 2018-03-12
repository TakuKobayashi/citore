natto = TextAnalyzer.get_natto

stream_client = TwitterRecord.get_twitter_stream_client("fey_kun_ai")
stream_client.user do |status|
  if status.in_reply_to_screen_name == "fey_kun_ai" && status.user.screen_name != "fey_kun_ai"
    inquiry_tweet = FeyKunAi::InquiryTweet.generate_tweet!(tweet: status)
    inquiry_tweet.check_and_request_analize
  end
end