# == Schema Information
#
# Table name: food_forecast_mst_foods
#
#  id             :integer          not null, primary key
#  food_id        :string(255)      not null
#  name           :string(255)      not null
#  classification :integer          default(0), not null
#  disposal       :float(24)        default(0.0), not null
#  kcal           :float(24)        default(0.0), not null
#  corrected_kcal :float(24)        default(0.0), not null
#
# Indexes
#
#  foods_classification_index  (classification)
#  foods_food_id_index         (food_id) UNIQUE
#  foods_name_index            (name)
#

class FoodForecast::MstFood < ApplicationRecord
end
