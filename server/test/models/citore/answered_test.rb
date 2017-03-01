# == Schema Information
#
# Table name: citore_answereds
#
#  id               :integer          not null, primary key
#  answer_user_type :string(255)      not null
#  answer_user_id   :integer          not null
#  input_word       :text(65535)      not null
#  output_word      :string(255)      not null
#  voice_id         :integer
#  image_id         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  citore_answered_user_index  (answer_user_type,answer_user_id)
#

require 'test_helper'

class Citore::AnsweredTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
