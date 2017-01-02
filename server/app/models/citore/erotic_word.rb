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
  ERO_KOTOBA_BOT = "ero_kotoba_bot"

  ERO_KOTOBA_KEY = "ero_kotoba"
end
