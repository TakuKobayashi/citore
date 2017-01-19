# == Schema Information
#
# Table name: emotional_words
#
#  id       :integer          not null, primary key
#  word     :string(255)      not null
#  language :integer          default("japanese"), not null
#  reading  :string(255)      not null
#  part     :string(255)      not null
#  score    :float(24)        not null
#
# Indexes
#
#  index_emotional_words_on_word_and_part_and_reading  (word,part,reading) UNIQUE
#

require 'test_helper'

class EmotionalWordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
