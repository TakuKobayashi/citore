# == Schema Information
#
# Table name: citore_aegigoe_words
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
#  index_citore_aegigoe_words_on_twitter_word_id  (twitter_word_id)
#

class Citore::AegigoeWord < TwitterRecord
  AEGIGOE_BOT = "aegigoe_bot"

  def self.generate!(text, twitter_word_id = nil)
    reading = ApplicationRecord.reading(text)
    aegigoe_word = Citore::AegigoeWord.find_or_initialize_by(reading: reading)
    new_record = erotic_word.new_record?
    if new_record
      aegigoe_word.origin = text
      aegigoe_word.twitter_word_id = twitter_word_id
    end
    aegigoe_word.appear_count = erotic_word.appear_count + 1
    aegigoe_word.save!
    return aegigoe_word
  end
end
