# == Schema Information
#
# Table name: word_to_markovs
#
#  id                :integer          not null, primary key
#  source_type       :string(255)      not null
#  source_id         :integer          not null
#  markov_trigram_id :integer          not null
#
# Indexes
#
#  word_to_markovs_index         (markov_trigram_id,source_type,source_id)
#  word_to_markovs_source_index  (source_type,source_id)
#

require 'test_helper'

class WordToMarkovTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
