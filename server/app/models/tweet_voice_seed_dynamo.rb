class TweetVoiceSeedDynamo
  include Aws::Record

  string_attr :key,  hash_key: true
  string_attr :reading
  map_attr    :info
end
