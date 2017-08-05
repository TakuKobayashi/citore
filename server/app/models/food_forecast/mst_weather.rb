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

class FoodForecast::MstWeather < ApplicationRecord
  enum factor: [
    :typhoon, #台風接近
    :humidity, #湿度
    :temperature, #気温
    :rainy_season, #梅雨
    :ultraviolet_rays, #紫外線
    :pm_2_5, #PM 2.5
    :difference_temperature, #寒暖の差が激しい
    :strong_wind #強風
  ]

  enum inequality: [
    :greater_than,
    :greater_equal,
    :equal,
    :lower_equal,
    :lower_than
  ]

  has_many :weather_healthes, class_name: 'FoodForecast::WeatherHealth', foreign_key: :mst_weather_id
end
