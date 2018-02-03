# == Schema Information
#
# Table name: hackathon_musichackday2018_users
#
#  id               :integer          not null, primary key
#  token            :string(255)      not null
#  last_accessed_at :datetime         not null
#  user_agent       :text(65535)
#  options          :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_hackathon_musichackday2018_users_on_last_accessed_at  (last_accessed_at)
#  index_hackathon_musichackday2018_users_on_token             (token) UNIQUE
#

require 'test_helper'

class Hackathon::Musichackday2018::UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
