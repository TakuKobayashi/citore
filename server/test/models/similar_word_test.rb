# == Schema Information
#
# Table name: similar_words
#
#  id           :integer          not null, primary key
#  from_word_id :integer          not null
#  to_word_id   :integer          not null
#  score        :float(24)        default(0.0), not null
#  from_key     :string(255)      default(""), not null
#
# Indexes
#
#  similar_words_indexes  (from_word_id,to_word_id,from_key) UNIQUE
#

require 'test_helper'

class SimilarWordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
