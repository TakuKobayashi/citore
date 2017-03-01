# == Schema Information
#
# Table name: linebot_follower_users
#
#  id             :integer          not null, primary key
#  type           :string(255)      not null
#  line_user_id   :string(255)      not null
#  display_name   :string(255)      not null
#  picture_url    :string(255)
#  status_message :text(65535)
#  unfollow       :boolean          default(TRUE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_linebot_follower_users_on_line_user_id_and_type  (line_user_id,type) UNIQUE
#

class Citore::LinebotFollowerUser < LinebotFollowerUser
  has_many :answers, as: :answer_user, class_name: 'Citore::Answered'

  def search_and_generate_answer!(event:)
    natto = ApplicationRecord.get_natto
    sanitaized_word = ApplicationRecord.basic_sanitize(event.message['text'].to_s)
    reading = ApplicationRecord.reading(sanitaized_word)
    split_words = ApplicationRecord.ngram(reading, 2).uniq
    ngrams = NgramWord.where(from_type: "Citore::EroticWord", bigram: split_words).includes(:from)
    erotic_word = ngrams.map(&:from).uniq.select{|citore_erotic_word| reading.include?(citore_erotic_word.reading) }.sample

    answer = self.answers.new(input_word: event.message['text'].to_s)
    if erotic_word.present?
      voice = erotic_word.voices.sample
      answer.voice_id = voice.id
      answer.output_word = "エ?\n#{erotic_word.origin}\n(#{erotic_word.reading})"
    else
      answer.output_word = Citore::LinebotFollowerUser.get_random_message
    end
    answer.save!
    return answer
  end

  def self.get_random_message
    erotic_rand = Citore::EroticWord.all.sample
    return MarkovTrigramPrefix.generate_sentence(seed: erotic_rand.origin, source_type: "TwitterWord")
  end
end
