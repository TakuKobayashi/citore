# == Schema Information
#
# Table name: sugarcoat_answereds
#
#  id               :integer          not null, primary key
#  answer_user_type :string(255)      not null
#  answer_user_id   :integer          not null
#  input_word       :text(65535)      not null
#  input_score      :float(24)        default(0.0), not null
#  output_word      :string(255)      not null
#  output_score     :float(24)        default(0.0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_sugarcoat_answereds_on_input_score   (input_score)
#  index_sugarcoat_answereds_on_output_score  (output_score)
#  sugarcoat_answered_user_index              (answer_user_type,answer_user_id)
#

class Sugarcoat::Answered < ApplicationRecord
  belongs_to :answer_user, polymorphic: true
end
