class VoiceDynamo
  include Aws::Record

  string_attr :word,  hash_key: true
  string_attr :speaker_name, range_key: true
  map_attr    :info
end
