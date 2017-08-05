# == Schema Information
#
# Table name: food_forecast_food_recipes
#
#  id          :integer          not null, primary key
#  mst_food_id :integer          not null
#  weight      :float(24)        default(1.0), not null
#  url         :string(255)      not null
#  content     :text(65535)
#
# Indexes
#
#  food_forecast_recipe_food_id_index  (mst_food_id)
#

require 'test_helper'

class FoodForecast::FoodRecipeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
