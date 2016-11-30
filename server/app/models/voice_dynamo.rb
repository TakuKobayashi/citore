class VoiceDynamo
  include Aws::Record

  string_attr :word,  hash_key: true
  string_attr :speaker_name, range_key: true
  string_attr :uuid
  string_attr :file_path
  string_attr :recource_type
  map_attr   :generate_params
  map_attr   :options
end
