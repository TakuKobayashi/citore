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

class FoodForecast::WeatherHealth < ApplicationRecord
  belongs_to :weather, class_name: 'FoodForecast::MstWeather', foreign_key: :mst_weather_id, required: false
  belongs_to :health, class_name: 'FoodForecast::MstHealth', foreign_key: :mst_health_id, required: false
end
