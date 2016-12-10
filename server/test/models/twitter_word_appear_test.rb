# == Schema Information
#
# Table name: twitter_word_appears
#
#  id                   :integer          not null, primary key
#  tweet_appear_word_id :integer          not null
#  twitter_word_id      :integer          not null
#
# Indexes
#
#  twitter_word_appears_relation_index  (tweet_appear_word_id,twitter_word_id)
#

require 'test_helper'

class TwitterWordAppearTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
