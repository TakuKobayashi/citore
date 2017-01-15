# == Schema Information
#
# Table name: markov_trigrams
#
#  id           :integer          not null, primary key
#  source_type  :string(255)      not null
#  first_gram   :string(255)      default(""), not null
#  second_gram  :string(255)      default(""), not null
#  third_gram   :string(255)      default(""), not null
#  appear_count :integer          default(0), not null
#
# Indexes
#
#  markov_trigram_type_word_index  (source_type,first_gram,second_gram,third_gram) UNIQUE
#  markov_trigram_word_index       (first_gram,second_gram,third_gram)
#

class MarkovTrigram < ApplicationRecord
  has_many :word_to_markovs
  has_many :lyrics, through: :word_to_markovs, source: :source, source_type: 'Lyric'
  has_many :twitter_words, through: :word_to_markovs, source: :source, source_type: 'TwitterWord'
  has_many :wikipedia_articles, through: :word_to_markovs, source: :source, source_type: 'WikipediaArticle'

  def joint
    return self.second_gram + self.third_gram
  end

  def self.generate_sentence(seed: , source_type: nil)
    word_records = {}
    candidates = MarkovTrigram.where(first_gram: "", second_gram: seed)
    sentence_array = []
    record = nil
    while
      # 初期化
      record = nil
      if word_records[record.try(:first_gram).to_s].present?
        candidates = word_records[record.try(:first_gram).to_s]
      else
        if source_type.present?
          candidates = candidates.where(source_type: source_type)
        end
      end
      #ActiveRecordなら SQL を発行させる
      candidates = candidates.to_a
      lot_value = rand(candidates.sum(&:appear_count))
      counter = 0
      candidates.each do |candidate|
        counter += candidate.appear_count
        if counter > lot_value
      	  record = candidate
          break
        end
      end
      # cacheとしていれる。 同じものは使わない
      word_records[record.try(:first_gram).to_s] = candidates.select{|r| r.id != record.try(:id).to_i }
      sentence_array << record
      candidates = MarkovTrigram.where(first_gram: record.third_gram).where.not(id: sentence_array.map(&:id))
    end while record.try(:third_gram).present?

    return sentence_array.map(&:joint).join("")
  end
end
