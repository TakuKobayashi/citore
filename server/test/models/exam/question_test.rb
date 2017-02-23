# == Schema Information
#
# Table name: exam_questions
#
#  id                   :integer          not null, primary key
#  exam_examination_id  :integer          not null
#  exam_explaination_id :integer
#  answer_category      :integer          default(0), not null
#  point                :float(24)        default(0.0), not null
#  number_word          :string(255)      default(""), not null
#  title                :text(65535)
#  body                 :text(65535)      not null
#  correct_answer       :text(65535)      not null
#
# Indexes
#
#  index_exam_questions_on_exam_examination_id   (exam_examination_id)
#  index_exam_questions_on_exam_explaination_id  (exam_explaination_id)
#

require 'test_helper'

class Exam::QuestionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
