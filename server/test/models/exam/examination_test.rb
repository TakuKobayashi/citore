# == Schema Information
#
# Table name: exam_examinations
#
#  id                  :integer          not null, primary key
#  type                :string(255)      not null
#  title               :string(255)      default(""), not null
#  version             :integer          default(0), not null
#  implementation_time :datetime         not null
#
# Indexes
#
#  index_exam_examinations_on_implementation_time  (implementation_time)
#

require 'test_helper'

class Exam::ExaminationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
