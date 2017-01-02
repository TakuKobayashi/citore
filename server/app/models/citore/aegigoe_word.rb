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
end
