# == Schema Information
#
# Table name: shiritori_rounds
#
#  id               :integer          not null, primary key
#  number           :integer          default(1), not null
#  activate         :boolean          default(TRUE), not null
#  winner_user_type :string(255)
#  winner_user_id   :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Shiritori::Round < ApplicationRecord
  has_many :answers, class_name: 'Shiritori::AnsweredWord', foreign_key: :shiritori_round_id
end
