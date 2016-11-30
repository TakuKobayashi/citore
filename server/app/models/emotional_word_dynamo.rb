class EmotionalWordDynamo
  include Aws::Record

  string_attr :word,  hash_key: true
  string_attr :reading, range_key: true
  string_attr :part, range_key: true
  float_attr :score
  map_attr   :options
end
