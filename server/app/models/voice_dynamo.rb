class VoiceDynamo
  include Aws::Record

  integer_attr :recource_id,  hash_key: true
  string_attr  :recource_type, range_key: true
  map_attr     :info
end
