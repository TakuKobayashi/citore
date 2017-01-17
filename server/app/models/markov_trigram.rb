# == Schema Information
#
# Table name: markov_trigrams
#
#  id          :integer          not null, primary key
#  source_type :string(255)      not null
#  prefix      :string(255)      default(""), not null
#  others_json :text(65535)      not null
#  state       :integer          default(0), not null
#
# Indexes
#
#  index_markov_trigrams_on_prefix_and_state  (prefix,state) UNIQUE
#

class MarkovTrigram < ApplicationRecord
  serialize :others_json, JSON

  enum state: [:normal, :bos, :eos]

  has_many :word_to_markovs
  has_many :lyrics, through: :word_to_markovs, source: :source, source_type: 'Lyric'
  has_many :twitter_words, through: :word_to_markovs, source: :source, source_type: 'TwitterWord'
  has_many :wikipedia_articles, through: :word_to_markovs, source: :source, source_type: 'WikipediaArticle'

  def others
    #cache
    @others_array ||= others_json
  end

  def joint
    return self.second_gram + self.third_gram
  end

  def self.generate_sentence(seed: , source_type: nil)
    word_records = {}
    markovs = MarkovTrigram.bos.where(prefix: seed)
    sentence_array = []
    markov = nil
    counter = 0
    begin
      # cacheがアレばそこから引っ張る
      if word_records[markov.try(:prefix).to_s].present? || markovs.instance_of?(Array)
        markovs = word_records[markov.try(:prefix).to_s]
      else
        if source_type.present?
          markovs = markovs.where(source_type: source_type).limit(1)
        end
      end
      # 一つ前のrecordの情報はもういらないので初期化
      other_word = nil
      #ActiveRecordなら SQL を発行させる
      markovs = markovs.to_a
      candidates = markovs.map(&:others).flatten
      lot_value = rand(candidates.sum{|c| c["appear_count"].to_i })
      counter = 0
      candidates.each do |candidate|
        counter += candidate["appear_count"].to_i
        if counter > lot_value
      	  other_word = candidate
          break
        end
      end

      # 今引き当てたものは次に出ないようにするために除外する
      markovs.each{|m| m.others.select{|r| r["second_word"] != other_word["second_word"] && r["third_word"] != other_word["third_word"] } }
      # prefixはどれも同じはず
      markov = markovs.sample
      # cacheとしていれる。 同じものは使わない
      word_records[markov.try(:prefix).to_s] = markovs
      if counter == 0
        sentence_array << markov.prefix
      end
      sentence_array += [other_word["second_word"], other_word["third_word"]]
      counter = counter + 1
      markovs = MarkovTrigram.where(prefix: other_word["third_word"].to_s)
    end while markov.blank? || markov.eos?

    return sentence_array.flatten.join("")
  end
end
