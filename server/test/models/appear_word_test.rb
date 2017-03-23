# == Schema Information
#
# Table name: appear_words
#
#  id             :integer          not null, primary key
#  appear_count   :integer          default(0), not null
#  word           :string(255)      not null
#  part           :string(255)      not null
#  reading        :string(255)      default(""), not null
#  sentence_count :integer          default(0), not null
#
# Indexes
#
#  index_appear_words_on_reading                    (reading)
#  index_appear_words_on_word_and_part_and_reading  (word,part,reading) UNIQUE
#

require 'test_helper'

class AppearWordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
