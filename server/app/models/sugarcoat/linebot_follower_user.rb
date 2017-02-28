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

class Sugarcoat::LinebotFollowerUser < LinebotFollowerUser
  has_many :answers, as: :answer_user, class_name: 'Sugarcoat::Answered'

  def say!(event: event)
    input = event.message['text']
    output = Sugarcoat::LinebotFollowerUser.get_output(input)
    # キーワード抽出してseq2seq or fasttext
    answers.create!(input_word: input,output_word: output)
    return output
  end

  def self.get_output(message)
    prefix_rand_id = rand(MarkovTrigramPrefix.where(type: "TwitterWord").last.id)
    prefix = MarkovTrigramPrefix.where(type: "TwitterWord").where("id > ?", prefix_rand_id).first
    return MarkovTrigramPrefix.generate_sentence(seed: prefix.prefix, source_type: "TwitterWord")
  end
end
