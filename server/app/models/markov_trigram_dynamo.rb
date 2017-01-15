class MarkovTrigramDynamo
  include Aws::Record

  string_attr :source_type,  hash_key: true
  string_attr :first_gram, range_key: true
  string_attr :second_gram, range_key: true
  string_attr :third_gram, range_key: true
  integer_attr :appear_count
  integer_attr :id
end
