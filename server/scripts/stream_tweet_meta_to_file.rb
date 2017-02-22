apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
TweetStream.configure do |config|
  config.consumer_key       = apiconfig["twitter"]["consumer_key"]
  config.consumer_secret    = apiconfig["twitter"]["consumer_secret"]
  config.oauth_token        = apiconfig["twitter"]["access_token_key"]
  config.oauth_token_secret = apiconfig["twitter"]["access_token_secret"]
  config.auth_method        = :oauth
end

natto = ApplicationRecord.get_natto

directory_name = Rails.root.to_s + "/tmp/tweet_csv"
Dir.mkdir(directory_name) unless File.exists?(directory_name)

now_str = Time.now.strftime("%Y%m%d")
reply_file_path = Rails.root.to_s + "/tmp/tweet_csv/#{now_str}_reply.csv"
unless File.exists?(reply_file_path)
  out_file = File.new(reply_file_path,"w")
  out_file.puts(["twitter_user_id", "twitter_user_name", "twitter_tweet_id", "tweet", "csv_url", "tweet_created_at", "reply_to_tweet_id"].join(","))
  out_file.close
end
reply_file = File.new(reply_file_path,"a")

location_file_path = Rails.root.to_s + "/tmp/tweet_csv/#{now_str}_locationi.csv"
unless File.exists?(location_file_path)
  out_file = File.new(location_file_path,"w")
  out_file.puts(["twitter_user_id", "twitter_user_name", "twitter_tweet_id", "tweet", "csv_url", "tweet_created_at", "reply_to_tweet_id", "lat", "lon", "place_name"].join(","))
  out_file.close
end
location_file = File.new(location_file_path,"a")

rep_ids = []

client = TweetStream::Client.new
client.sample do |status|
  next if status.lang != "ja"
  next if !status.in_reply_to_status_id? && !status.geo?
  p "#{status.in_reply_to_status_id}:#{status.geo}"
  sanitaized_word = TwitterRecord.sanitized(status.text)
  sanitaized_word = sanitaized_word.gsub("\n"," ").gsub(",",".")
  without_url_tweet, urls = ApplicationRecord.separate_urls(sanitaized_word)

  csv_arr = [status.user.id.to_s, status.user.screen_name.to_s, status.id.to_s, without_url_tweet, urls.to_json, status.created_at, status.in_reply_to_status_id.to_s]
  if status.in_reply_to_status_id?
    reply_file.puts(csv_arr.join(","))
    rep_ids << status.in_reply_to_status_id
  end
  if status.geo?
    csv_arr += status.geo.coordinates
    csv_arr << status.place.full_name
    location_file.puts(csv_arr.join(","))
  end

  if rep_ids.size >= 100
    p "pool"
    reply_statuses = TwitterRecord.get_tweets(rep_ids)
    rep_ids = []
    reply_statuses.each do |reply_status|
      next if reply_status.lang != "ja"
      next if !reply_status.in_reply_to_status_id? && !reply_status.geo?
      sanitaized_word = TwitterRecord.sanitized(reply_status.text)
      sanitaized_word.gsub!("\n", " ")
      without_url_tweet, urls = ApplicationRecord.separate_urls(sanitaized_word)

      csv_arr = [reply_status.user.id.to_s, reply_status.user.screen_name.to_s, reply_status.id.to_s, without_url_tweet, urls.to_json, reply_status.created_at, reply_status.in_reply_to_status_id.to_s]
      if reply_status.in_reply_to_status_id?
        reply_file.puts(csv_arr.join(","))
        rep_ids << reply_status.in_reply_to_status_id
      end
      if reply_status.geo?
        csv_arr += reply_status.geo.coordinates
        csv_arr << reply_status.place.full_name
        location_file.puts(csv_arr.join(","))
      end
    end
    p "after:#{rep_ids.size}"
  end
end