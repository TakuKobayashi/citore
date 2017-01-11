# == Schema Information
#
# Table name: lyric_appear_words
#
#  id             :integer          not null, primary key
#  lyric_id       :integer          not null
#  appear_word_id :integer          not null
#
# Indexes
#
#  lyric_appear_words_index  (lyric_id,appear_word_id)
#

require 'test_helper'

class LyricAppearWordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
