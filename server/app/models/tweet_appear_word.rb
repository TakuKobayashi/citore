# == Schema Information
#
# Table name: tweet_appear_words
#
#  id           :integer          not null, primary key
#  appear_count :integer          default(0), not null
#  word         :string(255)      not null
#  part         :string(255)      not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_tweet_appear_words_on_word_and_part  (word,part) UNIQUE
#

class TweetAppearWord < ApplicationRecord
  has_many :tweet_words
end
