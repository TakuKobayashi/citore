class MarkovTrigramDynamo
  include Aws::Record

  string_attr :prefix, hash_key: true
  string_attr :source_type, range_key: true
  integer_attr :id
  integer_attr :state
  array_attr :others_json
end
