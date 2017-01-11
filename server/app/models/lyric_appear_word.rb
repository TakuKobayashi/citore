# == Schema Information
#
# Table name: lyric_appear_words
#
#  id             :integer          not null, primary key
#  lyric_id       :integer          not null
#  appear_word_id :integer          not null
#
# Indexes
#
#  lyric_appear_words_index  (lyric_id,appear_word_id)
#

class LyricAppearWord < ApplicationRecord
  belongs_to :appear_word
  belongs_to :lyric
end
