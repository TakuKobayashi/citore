# == Schema Information
#
# Table name: twitter_words
#
#  id                   :integer          not null, primary key
#  tweet_appear_word_id :integer          not null
#  twitter_user_id      :string(255)      not null
#  twitter_user_name    :string(255)
#  twitter_tweet_id     :string(255)      not null
#  tweet_created_at     :datetime         not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_twitter_words_on_tweet_appear_word_id  (tweet_appear_word_id)
#  index_twitter_words_on_tweet_created_at      (tweet_created_at)
#  index_twitter_words_on_twitter_user_id       (twitter_user_id)
#

require 'test_helper'

class TwitterWordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
