# == Schema Information
#
# Table name: food_forecast_user_weather_locations
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  lat             :float(24)
#  lon             :float(24)
#  ip_address      :string(255)      not null
#  address         :string(255)
#  accessed_at     :datetime         not null
#  weather_reports :text(65535)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  user_weather_locations_accessed_at_index  (accessed_at)
#  user_weather_locations_ip_address_index   (ip_address)
#  user_weather_locations_lat_lon_index      (lat,lon)
#  user_weather_locations_user_id_index      (user_id)
#

require 'test_helper'

class FoodForecast::UserWeatherLocationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
