# == Schema Information
#
# Table name: food_forecast_health_foods
#
#  id            :integer          not null, primary key
#  mst_health_id :integer          not null
#  mst_food_id   :integer          not null
#  weight        :float(24)        default(1.0), not null
#
# Indexes
#
#  health_food_relation_index  (mst_health_id,mst_food_id)
#

class FoodForecast::HealthFood < ApplicationRecord
  belongs_to :health, class_name: 'FoodForecast::MstHealth', foreign_key: :mst_health_id, required: false
  belongs_to :food, class_name: 'FoodForecast::MstFood', foreign_key: :mst_food_id, required: false
end
