# == Schema Information
#
# Table name: food_forecast_mst_healths
#
#  id     :integer          not null, primary key
#  name   :string(255)      not null
#  column :text(65535)
#

class FoodForecast::MstHealth < ApplicationRecord
  has_many :weather_healthes, class_name: 'FoodForecast::WeatherHealth', foreign_key: :mst_health_id
end
