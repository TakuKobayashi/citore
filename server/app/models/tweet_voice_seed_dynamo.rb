class TweetVoiceSeedDynamo
  include Aws::Record

  string_attr :key,  hash_key: true
  string_attr :reading, range_key: true
  map_attr    :info
end
