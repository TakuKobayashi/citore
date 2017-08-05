# == Schema Information
#
# Table name: food_forecast_mst_weathers
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  factor     :integer          not null
#  inequality :integer          not null
#  threshold  :float(24)        default(0.0), not null
#
# Indexes
#
#  weather_factor_index  (factor) UNIQUE
#

require 'test_helper'

class FoodForecast::MstWeatherTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
