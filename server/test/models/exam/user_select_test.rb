# == Schema Information
#
# Table name: exam_user_selects
#
#  id                :integer          not null, primary key
#  answer_user_type  :string(255)      not null
#  answer_user_id    :integer          not null
#  current_exam_type :string(255)      not null
#  activate          :boolean          default(TRUE), not null
#  started_at        :datetime         not null
#  canceled_at       :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  exam_user_select_time_index  (started_at,canceled_at)
#  exam_user_select_user_index  (answer_user_type,answer_user_id)
#

require 'test_helper'

class Exam::UserSelectTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
