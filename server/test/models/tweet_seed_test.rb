# == Schema Information
#
# Table name: tweet_seeds
#
#  id             :integer          not null, primary key
#  tweet_id_str   :string(255)      not null
#  tweet          :string(255)      not null
#  search_keyword :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_tweet_seeds_on_search_keyword  (search_keyword)
#  index_tweet_seeds_on_tweet_id_str    (tweet_id_str) UNIQUE
#

require 'test_helper'

class TweetSeedTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
