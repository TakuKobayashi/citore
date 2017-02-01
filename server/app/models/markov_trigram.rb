# == Schema Information
#
# Table name: markov_trigrams
#
#  id          :integer          not null, primary key
#  source_type :string(255)      not null
#  prefix      :string(255)      default(""), not null
#  others_json :text(4294967295) not null
#  state       :integer          default("normal"), not null
#
# Indexes
#
#  index_markov_trigrams_on_prefix_and_state  (prefix,state) UNIQUE
#

class MarkovTrigram < ApplicationRecord

  #[
  #  {
  #    second_word: string,
  #    third_word: string,
  #    appear_count: integer,
  #  },
  #]
  serialize :others_json, JSON

  enum state: [:normal, :bos, :eos]

  def others
    #cache
    @others_array ||= others_json
  end

  def others=(hash)
    #cache
    array = others || []
    if array.any?{|r| r["second_word"] == hash["second_word"] && r["third_word"] == hash["third_word"]}
      array.each do |h|
        if h["second_word"] == hash["second_word"] && h["third_word"] == hash["third_word"]
          h["appear_count"] = h["appear_count"].to_i + 1
          break
        end
      end
    else
      array << hash.merge("appear_count" => 1)
    end
    # 候補がいっぱいある時は頻出単語以外は抽選していくスタイル
    #if array.size > 25000
    #  major, minor = array.partition{|a| a["appear_count"] > 1 }
    #  result = major + minor.sample(25000 - major.size)
    #else
      result = array
    #end
    self.others_json = result
    @others_array = result
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
