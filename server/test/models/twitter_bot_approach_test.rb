# == Schema Information
#
# Table name: twitter_bot_approaches
#
#  id                :integer          not null, primary key
#  twitter_user_id   :string(255)      not null
#  twitter_user_name :string(255)      not null
#  action            :integer          not null
#  twitter_tweet_id  :string(255)
#  tweet             :string(255)
#
# Indexes
#
#  index_twitter_bot_approaches_on_twitter_tweet_id  (twitter_tweet_id)
#  index_twitter_bot_approaches_on_twitter_user_id   (twitter_user_id)
#

require 'test_helper'

class TwitterBotApproachTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
