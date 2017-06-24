# == Schema Information
#
# Table name: fey_kun_ai_inquiry_tweets
#
#  id                :integer          not null, primary key
#  twitter_user_id   :string(255)      not null
#  twitter_user_name :string(255)      not null
#  tweet_id          :string(255)      not null
#  tweet             :string(255)      not null
#  token             :string(255)      not null
#  return_tweet      :string(255)
#  place_name        :string(255)
#  lat               :float(24)
#  lon               :float(24)
#  tweet_quoted_id   :integer
#  tweet_created_at  :datetime         not null
#
# Indexes
#
#  fka_inquiry_lat_lon_index    (lat,lon)
#  fka_inquiry_quoted_id_index  (tweet_quoted_id)
#  fka_inquiry_token_index      (token) UNIQUE
#  fka_inquiry_tweet_id_index   (tweet_id) UNIQUE
#  fka_inquiry_user_id_index    (twitter_user_id)
#  fka_inquiry_user_name_index  (twitter_user_name)
#

require 'test_helper'

class FeyKunAi::InquiryTweetTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
