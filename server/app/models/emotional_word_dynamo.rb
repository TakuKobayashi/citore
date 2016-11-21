class EmotionalWordDynamo
  include Aws::Record

  string_attr :word,  hash_key: true
  string_attr :part, range_key: true
  map_attr    :info
end
