# == Schema Information
#
# Table name: food_forecast_mst_food_recipes
#
#  id          :integer          not null, primary key
#  mst_food_id :integer          not null
#  weight      :float(24)        default(1.0), not null
#  url         :string(255)      not null
#  content     :text(65535)
#

require 'test_helper'

class FoodForecast::MstFoodRecipeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
