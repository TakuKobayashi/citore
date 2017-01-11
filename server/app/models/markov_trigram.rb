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
end