# == Schema Information
#
# Table name: markov_trigram_words
#
#  id                       :integer          not null, primary key
#  markov_trigram_prefix_id :integer          not null
#  second_word              :string(255)      default(""), not null
#  third_word               :string(255)      default(""), not null
#  appear_count             :integer          default(0), not null
#
# Indexes
#
#  markov_trigram_words_indexes  (markov_trigram_prefix_id,second_word,third_word) UNIQUE
#

class MarkovTrigramWord < ApplicationRecord
end
