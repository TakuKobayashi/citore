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
#  index_markov_trigram_words_on_markov_trigram_prefix_id  (markov_trigram_prefix_id)
#

class MarkovTrigramWord < ApplicationRecord
end
