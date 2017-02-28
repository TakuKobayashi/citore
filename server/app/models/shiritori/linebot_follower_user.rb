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

class Shiritori::LinebotFollowerUser < LinebotFollowerUser
  has_many :answers, as: :answer_user, class_name: 'Shiritori::AnsweredWord'

  def generate_return_message!(message: )
  	#半角カナとかをいい感じに
  	sanitaized_word = basic_sanitize(message)
  	#記号を除去
    sanitaized_word = delete_symbols(sanitaized_word)
    if sanitaized_word.match(/(?:\p{Hiragana}|\p{Katakana}|[一-龠々])+/).nil?
      return "日本語でOK?"
    elsif !sanitaized_word.match(/(\p{Hiragana}|\p{Katakana})+/).nil? && sanitaized_word <= 1
      return "えーと...なにを言っているのかよくわからんなぁ..."
    end
    reading_array = []
    natto = ApplicationRecord.get_natto
    natto.parse(sanitaized_word) do |n|
      next if n.surface.blank?
      csv = n.feature.split(",")
      reading = csv[7]
      if reading.blank?
        reading = n.surface
      end
      reading_array << reading
    end
    if reading_array.size > 1
      return "単語でOK?"
    end
    reading_word = reading_array.join
    if reading_word.blank?
      return "どうした?無言か?"
    end
    current_round = Shiritori::Round.find_or_create_by(activate: true)
    answered = current_round.answers.find_by(input_word: sanitaized_word)
    if answered.present?
      return answered.output_word
    end
    candidates = AppearWord.where("reading LIKE ?", reading_word.last.to_s + "%")
    rightwords , ngwords = candidates.partition{|w| w.reading.last != "ン" }
    answered_word_ids = current_round.answers.where(output_word: rightwords.map(&:word)).pluck(:answered_word_id)
    return_word = rightwords.reject{|r| answered_word_ids.include?(r.id) }.sample
    if return_word.blank?
      ngword = ngwords.sample
      current_round.transaction do
        current_round.answers.create!(answer_user: self, input_word: sanitaized_word, output_word: ngword.word, answered_word_id: ngword.id)
        current_round.update!(activate: false, winner_user: self)
        Shiritori::Round.create!(current_round.number + 1, activate: true)
      end
      return ngword.word_and_read + "\n\n...\nOh...\n負けました。"
    else
      current_round.answers.create!(answer_user: self, input_word: sanitaized_word, output_word: return_word.word, answered_word_id: return_word.id)
      return return_word.word_and_read
    end
  end
end