# == Schema Information
#
# Table name: appear_words
#
#  id           :integer          not null, primary key
#  appear_count :integer          default(0), not null
#  word         :string(255)      not null
#  part         :string(255)      not null
#
# Indexes
#
#  index_tweet_appear_words_on_word_and_part  (word,part) UNIQUE
#

class AppearWord < ApplicationRecord
  def self.get_keywords(text: , word_num: 3)
  	word_parts = []
    #TF-IDF法
    natto = ApplicationRecord.get_natto
    natto.parse(text) do |n|
      next if n.surface.blank?
      csv = n.feature.split(",")
      part = EmotionalWord::PARTS[csv[0]]
      next if part.blank? || part == "av"
      if csv[6] == "*"
        word_parts << [n.surface, part]
      else
        word_parts << [csv[6], part]
      end
    end
    grouping_words = word_parts.group_by{|w| w }
    index_words = AppearWord.where(word: grouping_words.keys.map{|w| w[0] }).index_by{|a| [a.word, a.part] }
    sorted_words = grouping_words.sort_by do |g, w|
      if index_words[g].blank?
        Float::INFINITY
      else
      	# tfを算出
        tf = w.size / word_parts.size
        sum_count = ExtraInfo.read_extra_info["sum_appear_word_count"] || AppearWord.sum(:appear_count)
        #idf (厳密には文章数ではないが。無作為に選んだ文章から頻出する単語を抜き出している中の総数なのでこれでも要件は満たせるのかなと)
        idf = Math.log(index_words[g].appear_count.to_f / sum_count.to_i)
        tf * idf
      end
    end
    results sorted_words.slice(0..(word_num - 1)).map do |sw|
      if index_words[sw].blank?
        AppearWord.new(appear_count: 1, word: sw[0], part: sw[1])
      else
        index_words[sw]
      end
    end
    return results
  end
end
