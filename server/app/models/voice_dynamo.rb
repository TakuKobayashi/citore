class VoiceDynamo
  include Aws::Record

  string_attr :word,  hash_key: true
  string_attr :recource_type, range_key: true
  map_attr    :info
end
