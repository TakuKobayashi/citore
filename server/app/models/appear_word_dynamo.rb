class AppearWordDynamo
  include Aws::Record

  string_attr :word,  hash_key: true
  string_attr :part, range_key: true
  integer_attr :appear_count
  integer_attr :id
end
