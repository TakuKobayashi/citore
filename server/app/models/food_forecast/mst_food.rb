# == Schema Information
#
# Table name: food_forecast_mst_foods
#
#  id             :integer          not null, primary key
#  food_id        :string(255)      not null
#  name           :string(255)      not null
#  classification :integer          default("cereals"), not null
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
  enum classification: [
    :cereals, #穀類
    :starch,  #いも・でんぷん類
    :seeds, #種実類
    :fruits, #果実類
    :vegetables, #野菜類
    :seaweeds, #海藻類
    :mushrooms, #きのこ類
    :pulses, #豆類
    :Meats, #肉類
    :seefoods, #魚介類
    :Eggs, #卵類
    :milk, #乳類
    :oils, #油脂類
    :sugar, #砂糖
    :sweetness, #砂糖・甘味類
    :beverages, #嗜好飲料類
    :seasonings #調味料・香辛料類
  ]

  CLASSIFICATION_WORDS = {
    cereals: "穀類",
    starch:  "いも・でんぷん類",
    seeds: "種実類",
    fruits: "果実類",
    vegetables: "野菜類",
    seaweeds: "海藻類",
    mushrooms: "きのこ類",
    pulses: "豆類",
    meats: "肉類",
    seefoods: "魚介類",
    eggs: "卵類",
    milk: "乳類",
    oils: "油脂類",
    sugar: "砂糖",
    sweetness: "砂糖・甘味類",
    beverages: "嗜好飲料類",
    seasonings: "調味料・香辛料類"
  }

  has_many :components, class_name: 'FoodForecast::MstFoodComponent', foreign_key: :mst_food_id
  has_many :health_foods, class_name: 'FoodForecast::HealthFood', foreign_key: :mst_food_id
end
