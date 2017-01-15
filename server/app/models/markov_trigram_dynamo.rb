class MarkovTrigramDynamo
  include Aws::Record

  string_attr :first_gram, hash_key: true
  integer_attr :id, range_key: true
  string_attr :source_type, range_key: true
  string_attr :second_gram
  string_attr :third_gram
  integer_attr :appear_count
end
