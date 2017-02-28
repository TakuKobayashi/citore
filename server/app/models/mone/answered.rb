# == Schema Information
#
# Table name: mone_answereds
#
#  id               :integer          not null, primary key
#  answer_user_type :string(255)      not null
#  answer_user_id   :integer          not null
#  input_word       :text(65535)      not null
#  output_word      :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  mone_answered_user_index  (answer_user_type,answer_user_id)
#

class Mone::Answered < ApplicationRecord
end
