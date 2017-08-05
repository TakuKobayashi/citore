# == Schema Information
#
# Table name: food_forecast_mst_food_components
#
#  id          :integer          not null, primary key
#  mst_food_id :integer          not null
#  factor      :integer          not null
#  value       :float(24)        default(0.0), not null
#
# Indexes
#
#  food_components_food_factor_index  (mst_food_id,factor)
#

require 'test_helper'

class FoodForecast::MstFoodComponentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
