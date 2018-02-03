# == Schema Information
#
# Table name: hackathon_musichackday2018_last_locations
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  log_id      :integer          not null
#  lat         :float(24)        default(0.0), not null
#  lon         :float(24)        default(0.0), not null
#  received_at :datetime         not null
#
# Indexes
#
#  index_hackathon_musichackday2018_last_locations_on_received_at  (received_at)
#  index_hackathon_musichackday2018_last_locations_on_user_id      (user_id)
#  musichackday2018_lat_lon_last_location_index                    (lat,lon)
#

require 'test_helper'

class Hackathon::Musichackday2018::LastLocationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
