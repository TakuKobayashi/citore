class EmotionalWordDynamo
  include Aws::Record

  string_attr :word,  hash_key: true
  string_attr :reading, range_key: true
  string_attr :part, range_key: true
  integer_attr :language
  float_attr :score

  PARTS = {
    "動詞" => "v",
    "形容詞" => "a",
    "名詞" => "n",
    "副詞" => "r",
    "助動詞" =>"av"
  }

  KAOMOJI_PART = "kao"
end
