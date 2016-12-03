# == Schema Information
#
# Table name: twitter_word_appears
#
#  id                   :integer          not null, primary key
#  tweet_appear_word_id :integer          not null
#  twitter_word_id      :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  twitter_word_appears_relation_index  (tweet_appear_word_id,twitter_word_id)
#

class TwitterWordAppear < ApplicationRecord
  belongs_to :tweet_appear_word
  belongs_to :twitter_word
end
