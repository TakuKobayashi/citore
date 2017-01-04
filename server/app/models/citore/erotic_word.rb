# == Schema Information
#
# Table name: citore_erotic_words
#
#  id              :integer          not null, primary key
#  twitter_word_id :integer
#  origin          :string(255)      not null
#  reading         :string(255)      not null
#  appear_count    :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_citore_erotic_words_on_twitter_word_id  (twitter_word_id)
#

class Citore::EroticWord < TwitterRecord
  has_many :ngrams, as: :from, class_name: 'NgramWord'
  has_many :voices, as: :from, class_name: 'VoiceWord'

  ERO_KOTOBA_BOT = "ero_kotoba_bot"

  ERO_KOTOBA_KEY = "ero_kotoba"

  def self.generate!(text, twitter_word_id = nil)
    reading = ApplicationRecord.reading(text)
    erotic_word = Citore::EroticWord.find_or_initialize_by(reading: reading)
    new_record = erotic_word.new_record?
    if new_record
      erotic_word.origin = text
      erotic_word.twitter_word_id = twitter_word_id
    end
    erotic_word.appear_count = erotic_word.appear_count + 1
    erotic_word.save!
    if new_record
      words = ApplicationRecord.ngram(reading, 2).uniq
      ngrams = words.map do |word|
        erotic_word.ngrams.new(bigram: word)
      end
      NgramWord.import!(ngrams)
    end
    return erotic_word
  end
end
