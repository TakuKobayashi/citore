# == Schema Information
#
# Table name: appear_words
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

class AppearWord < ApplicationRecord
  has_many :twitter_word_appears
  has_many :words, through: :twitter_word_appears, source: :twitter_word
end
