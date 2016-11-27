# == Schema Information
#
# Table name: emotional_word_dictionaries
#
#  id         :integer          not null, primary key
#  part       :string(255)      not null
#  word       :string(255)      not null
#  reading    :string(255)      not null
#  score      :float(24)        default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_emotional_word_dictionaries_on_reading  (reading)
#  index_emotional_word_dictionaries_on_word     (word)
#

class EmotionalWordDictionary < ApplicationRecord
  sugarcoat_database = YAML::load(IO.read(Rails.root.to_s + "/config/sugarcoat_database.yml"))
  establish_connection(sugarcoat_database[Rails.env])

  PARTS = {
    "動詞" => "v",
    "形容詞" => "a",
    "名詞" => "n",
    "副詞" => "r",
    "助動詞" =>"av"
  }
end
