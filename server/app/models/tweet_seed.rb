# == Schema Information
#
# Table name: tweet_seeds
#
#  id               :integer          not null, primary key
#  tweet_id_str     :string(255)      not null
#  tweet            :string(255)      not null
#  speech_file_path :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_tweet_seeds_on_tweet_id_str  (tweet_id_str) UNIQUE
#

class TweetSeed < ApplicationRecord
end
