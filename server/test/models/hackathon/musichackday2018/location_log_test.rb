# == Schema Information
#
# Table name: hackathon_musichackday2018_location_logs
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  lat        :float(24)        default(0.0), not null
#  lon        :float(24)        default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_hackathon_musichackday2018_location_logs_on_user_id  (user_id)
#  musichackday2018_lat_lon_log_index                         (lat,lon)
#

require 'test_helper'

class Hackathon::Musichackday2018::LocationLogTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
