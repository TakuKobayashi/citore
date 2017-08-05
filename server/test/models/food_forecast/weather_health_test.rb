# == Schema Information
#
# Table name: food_forecast_weather_healths
#
#  id             :integer          not null, primary key
#  mst_weather_id :integer          not null
#  mst_health_id  :integer          not null
#
# Indexes
#
#  weather_health_relation_index  (mst_weather_id,mst_health_id)
#

require 'test_helper'

class FoodForecast::WeatherHealthTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
