# == Schema Information
#
# Table name: exam_answered_words
#
#  id                  :integer          not null, primary key
#  answer_user_type    :string(255)      not null
#  answer_user_id      :integer          not null
#  answer_category     :integer          default(0), not null
#  exam_question_id    :integer          not null
#  exam_user_select_id :integer          not null
#  answer_text         :text(65535)
#  answer_choice_id    :integer
#  judge               :boolean          default(FALSE), not null
#  score               :float(24)        default(0.0), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  exam_answer_user_index                            (answer_user_type,answer_user_id)
#  index_exam_answered_words_on_answer_choice_id     (answer_choice_id)
#  index_exam_answered_words_on_exam_question_id     (exam_question_id)
#  index_exam_answered_words_on_exam_user_select_id  (exam_user_select_id)
#

class Exam::AnsweredWord < ApplicationRecord
end
