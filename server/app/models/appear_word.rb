# == Schema Information
#
# Table name: appear_words
#
#  id           :integer          not null, primary key
#  appear_count :integer          default(0), not null
#  word         :string(255)      not null
#  part         :string(255)      not null
#
# Indexes
#
#  index_tweet_appear_words_on_word_and_part  (word,part) UNIQUE
#

class AppearWord < ApplicationRecord
  has_many :twitter_word_appears
  has_many :words, through: :twitter_word_appears, source: :twitter_word
  has_many :lyric_appear_words
  has_many :lyrics, through: :lyric_appear_words, source: :lyric
  has_many :wikipedia_article_appear_words
  has_many :wikipedia_articles, through: :wikipedia_article_appear_words, source: :wikipedia_article
end
