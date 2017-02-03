# == Schema Information
#
# Table name: emotional_words
#
#  id       :integer          not null, primary key
#  word     :string(255)      not null
#  language :integer          default("japanese"), not null
#  reading  :string(255)      not null
#  part     :string(255)      not null
#  score    :float(24)        not null
#
# Indexes
#
#  index_emotional_words_on_word_and_part_and_reading  (word,part,reading) UNIQUE
#

class EmotionalWord < ApplicationRecord
  enum language: [:japanese, :english]
  PARTS = {
    "動詞" => "v",
    "形容詞" => "a",
    "名詞" => "n",
    "副詞" => "r",
    "助動詞" =>"av"
  }

  KAOMOJI_PART = "kao"

  def self.calc_score(text)
    hash = ExtraInfo.read_extra_info
    hash["en_average_score"].to_f
    hash["ja_average_score"].to_f
    natto = ApplicationRecord.get_natto
    word_parts = {}
    natto.parse(word) do |n|
      next if n.surface.blank?
      csv = n.feature.split(",")
      part = EmotionalWord::PARTS[csv[0]]
      next if part.blank? || part == "av"
      word_parts[n.surface] = part
    end
    words = EmotionalWord.where(word: word_parts.keys)
    words.sum{|w| w.score }
  end
end
