# == Schema Information
#
# Table name: exam_explainations
#
#  id                  :integer          not null, primary key
#  exam_examination_id :integer          not null
#  number_word         :string(255)      default(""), not null
#  large_category_name :string(255)      default(""), not null
#  title               :text(65535)
#  sub_title           :text(65535)
#  body                :text(65535)      not null
#
# Indexes
#
#  index_exam_explainations_on_exam_examination_id  (exam_examination_id)
#  index_exam_explainations_on_large_category_name  (large_category_name)
#

require 'test_helper'

class Exam::ExplainationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
