# == Schema Information
#
# Table name: food_forecast_mst_healths
#
#  id     :integer          not null, primary key
#  name   :string(255)      not null
#  column :text(65535)
#

class FoodForecast::MstHealth < ApplicationRecord
end
