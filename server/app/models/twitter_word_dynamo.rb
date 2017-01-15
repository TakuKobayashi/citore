class TwitterWordDynamo
  include Aws::Record

  string_attr  :twitter_tweet_id, hash_key: true
  string_attr  :twitter_user_id
  string_attr  :twitter_user_name
  string_attr :tweet
  integer_attr :id
  string_attr  :reply_to_tweet_id
  string_attr  :csv_url
  string_attr :tweet_created_at
end
