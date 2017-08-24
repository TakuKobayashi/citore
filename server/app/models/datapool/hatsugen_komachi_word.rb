# == Schema Information
#
# Table name: datapool_appear_words
#
#  id             :integer          not null, primary key
#  appear_count   :integer          default(0), not null
#  type           :string(255)
#  word           :string(255)      not null
#  part           :string(255)      not null
#  reading        :string(255)      not null
#  sentence_count :integer          default(0), not null
#
# Indexes
#
#  index_datapool_appear_words_on_reading        (reading)
#  index_datapool_appear_words_on_word_and_part  (word,part) UNIQUE
#

class Datapool::HatsugenKomachiWord < Datapool::AppearWord
end
