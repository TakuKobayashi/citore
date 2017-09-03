# == Schema Information
#
# Table name: datapool_appear_words
#
#  id             :integer          not null, primary key
#  appear_count   :integer          default(0), not null
#  type           :string(255)
#  word           :string(255)      not null
#  part           :string(255)      not null
#  reading        :string(255)      not null
#  sentence_count :integer          default(0), not null
#
# Indexes
#
#  index_datapool_appear_words_on_reading        (reading)
#  index_datapool_appear_words_on_word_and_part  (word,part) UNIQUE
#

class Datapool::AppearWord < ApplicationRecord
  def self.update_count_hash
    hash = {}
    types = Datapool::AppearWord.pluck(:type).uniq
    types.each do |t|
      counter_hash = {}
      all_sum = 0
      part_appear_sum = Datapool::AppearWord.where(type: t).group(:part).sum(:appear_count)
      part_appear_sum.each do |part, sum|
        counter_hash["#{part}_sum_appear_count"] = sum
        all_sum += sum
      end
      counter_hash["sum_appear_all_count"] = all_sum

      all_sum = 0
      part_sentence_sum = Datapool::AppearWord.where(type: t).group(:part).sum(:sentence_count)
      part_sentence_sum.each do |part, sum|
        counter_hash["#{part}_sum_sentence_count"] = sum
        all_sum += sum
      end
      counter_hash["sum_sentence_all_count"] = all_sum
      counter_hash["all_sentence_count"] = Datapool::AppearWord.where(type: t).count

      hash[t] = counter_hash
    end
    ExtraInfo.update({"appear_words" => hash})
  end

  def self.cached_count_hash(type_name: "Datapool::AppearWord")
    class_sum = ExtraInfo.read_extra_info["appear_words"] || {}
    return class_sum[type_name] || {}
  end

  def self.get_part_appear_sum(part:, type_name: "Datapool::AppearWord")
    self.cached_count_hash(type_name: type_name)["#{part}_sum_appear_count"] || self.where(part: part).sum(:appear_count)
  end

  def self.get_part_sentence_sum(part:, type_name: "Datapool::AppearWord")
    self.cached_count_hash(type_name: type_name)["#{part}_sum_sentence_count"] || self.where(part: part).sum(:sentence_count)
  end

  def self.get_appear_all_sum(type_name: "Datapool::AppearWord")
    self.cached_count_hash(type_name: type_name)["sum_appear_all_count"] || self.sum(:appear_count)
  end

  def self.get_sentence_all_sum(type_name: "Datapool::AppearWord")
    self.cached_count_hash(type_name: type_name)["sum_sentence_all_count"] || self.sum(:sentence_count)
  end

  def idf
    return Math.log(self.all_sentence_count.to_f / self.sentence_count.to_f)
  end

  def all_sentence_count
    all_count = self.class.cached_count_hash(type_name: self.type)["all_sentence_count"]
    if all_count.blank?
      all_count = Datapool::AppearWord.where(type: type).count
    end
    if all_count.to_i.zero?
      all_count = 1
    end
    return all_count.to_i
  end

  def appear_count_part_score
    return self.appear_count.to_f / self.class.get_part_appear_sum(part: self.part, type_name: self.type)
  end

  def sentence_count_part_score
    return self.sentence_count.to_f / self.class.get_part_sentence_sum(part: self.part, type_name: self.type)
  end

  def appear_count_all_score
    return self.appear_count.to_f / self.class.get_appear_all_sum(type_name: self.type)
  end

  def sentence_count_all_score
    return self.sentence_count.to_f / self.class.get_sentence_all_sum(type_name: self.type)
  end

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
