# == Schema Information
#
# Table name: twitter_word_appears
#
#  id              :integer          not null, primary key
#  appear_word_id  :integer          not null
#  twitter_word_id :integer          not null
#
# Indexes
#
#  twitter_word_appears_relation_index  (appear_word_id,twitter_word_id)
#

class TwitterWordAppear < TwitterRecord
  belongs_to :appear_word
  belongs_to :twitter_word
end
