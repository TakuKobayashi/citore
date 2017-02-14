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
    if array.size > 50000
      major, minor = array.partition{|a| a["appear_count"] > 1 }
      result = major + minor.sample(50000 - major.size)
    else
      result = array
    end
    self.others_json = result
    @others_array = result
  end

  def joint
    return self.second_gram + self.third_gram
  end
end
