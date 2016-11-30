class TweetVoiceSeedDynamo
  include Aws::Record

  string_attr :key,  hash_key: true
  string_attr :reading, range_key: true
  string_attr :tweet_id
  string_attr :origin
  integer_attr :tweet_user_id
  string_attr :tweet_user_name
  string_attr :uuid
  map_attr    :options
end
