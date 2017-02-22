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

require 'test_helper'

class Shiritori::RoundTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
