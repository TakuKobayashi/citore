# == Schema Information
#
# Table name: exam_question_choices
#
#  id               :integer          not null, primary key
#  exam_question_id :integer          not null
#  number_word      :string(255)      default(""), not null
#  number           :integer          default(1), not null
#  body             :text(65535)      not null
#
# Indexes
#
#  index_exam_question_choices_on_exam_question_id  (exam_question_id)
#

class Exam::QuestionChoice < ApplicationRecord
end
