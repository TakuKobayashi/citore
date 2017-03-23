# == Schema Information
#
# Table name: appear_words
#
#  id             :integer          not null, primary key
#  appear_count   :integer          default(0), not null
#  word           :string(255)      not null
#  part           :string(255)      not null
#  reading        :string(255)      default(""), not null
#  sentence_count :integer          default(0), not null
#
# Indexes
#
#  index_appear_words_on_reading                    (reading)
#  index_appear_words_on_word_and_part_and_reading  (word,part,reading) UNIQUE
#

class AppearWord < ApplicationRecord
  def self.calc_score_and_parts(text:)
    word_parts = {}
    #TF-IDF法
    natto = ApplicationRecord.get_natto
    natto.parse(text) do |n|
      next if n.surface.blank?
      csv = n.feature.split(",")
      part = EmotionalWord::PARTS[csv[0]]
      next if part.blank? || !["v", "a", "n"].include?(part)
      if csv[6] == "*"
        key = n.surface
      else
        key = csv[6]
      end
      word_parts[key] ||= []
      word_parts[key] << n
    end

    appear_words = AppearWord.where(word: word_parts.keys).group_by(&:word)

    text_words_sum = word_parts.sum{|n_arr| n_arr.size }
    sum_count = ExtraInfo.read_extra_info["sum_sentence_count"].to_f + 1

    result_hashes = []
    word_parts.each do |word, n_arr|
      # tfを算出
      tf = n_arr.size.to_f / text_words_sum.to_f
      appear_word_list = appear_words[word] || []
      # これまで出た文章の数 + 自分自身の数
      appear_count = appear_word_list.sum(&:sentence_count) + 1
      #idf
      idf = Math.log(sum_count.to_f / appear_count.to_f) + 1

      result = tf * idf
      result_hashes << {score: result, word: word, appear_words: appear_word_list, mecab_list: n_arr}
    end
    return result_hashes
  end

  def word_and_read
    return self.word + "\n(" + self.reading.tr('ァ-ン','ぁ-ん') + ")"
  end
end
