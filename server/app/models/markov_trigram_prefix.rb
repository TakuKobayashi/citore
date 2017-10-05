# == Schema Information
#
# Table name: markov_trigram_prefixes
#
#  id           :integer          not null, primary key
#  source_type  :string(255)      not null
#  prefix       :string(255)      default(""), not null
#  state        :integer          default("normal"), not null
#  unique_count :integer          default(0), not null
#  sum_count    :integer          default(0), not null
#
# Indexes
#
#  markov_trigram_prefixes_indexes  (prefix,state,source_type) UNIQUE
#

class MarkovTrigramPrefix < ApplicationRecord
  enum state: [:normal, :bos, :eos]
  has_many :other_words, class_name: 'MarkovTrigramWord', foreign_key: :markov_trigram_prefix_id

  def self.generate_sentence(seed: , source_type: nil)
    word_records = {}
    sentence_array = [seed]
    markovs = MarkovTrigramPrefix.where(prefix: seed)
    if source_type.present?
      select_source_type = source_type
      markov = markovs.find_by(source_type: source_type)
    else
      markov = markovs.to_a.sample
      select_source_type = markov.try(:source_type)
    end
    # 必ず何か引っ掛ける
    if markov.blank?
      lot_id = rand(MarkovTrigramPrefix.last.id)
      markov = MarkovTrigramPrefix.where("id >= ?", lot_id).first
      select_source_type = markov.try(:source_type)
    end

    loop do
      word_id_count = markov.other_words.pluck(:id, :appear_count)
      lot_value = rand(word_id_count.sum{|id, count| count})
      #lot_value = rand(markov.sum_count)
      lot_counter = 0
      select_word_id = nil
      word_id_count.each do |id, appear_count|
        lot_counter += appear_count.to_i
        if lot_counter > lot_value
      	  select_word_id = id
          break
        end
      end
      other_word = markov.other_words.find_by(id: select_word_id)
      sentence_array << other_word.joint
      markovs = MarkovTrigramPrefix.where(prefix: other_word.third_word.to_s, source_type: select_source_type, state: [MarkovTrigramPrefix.states[:normal], MarkovTrigramPrefix.states[:eos]])
      if sentence_array.sum(&:size) > 100
        markov = markovs.detect{|m| m.eos? }
        markov = markovs.sample if markov.blank?
      else
        markov = markovs.sample
      end

#      eos_words, continue_words = markovs.partition{|m| m.eos? }
#      if eos_words.present? && rand < 0.9
#        markov = eos_words.first
#      else
#        markov = continue_words.sample
#      end
      break if markov.blank? || markov.eos?
    end

    return sentence_array.join("")
  end
end
