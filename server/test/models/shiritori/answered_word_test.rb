# == Schema Information
#
# Table name: shiritori_answered_words
#
#  id                 :integer          not null, primary key
#  answer_user_type   :string(255)      not null
#  answer_user_id     :integer          not null
#  input_word         :string(255)      not null
#  output_word        :string(255)      not null
#  answered_word_id   :integer          not null
#  shiritori_round_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  shiritori_answer_input_round_index   (input_word,shiritori_round_id) UNIQUE
#  shiritori_answer_output_round_index  (output_word,shiritori_round_id) UNIQUE
#  shiritori_answer_user_index          (answer_user_type,answer_user_id)
#

require 'test_helper'

class Shiritori::AnsweredWordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
