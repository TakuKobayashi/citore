class CreateFoodForecastMstFoodRecipes < ActiveRecord::Migration[5.1]
  def change
    create_table :food_forecast_mst_food_recipes do |t|
      t.integer :mst_food_id, null: false
      t.float :weight, null: false, default: 1
      t.string :url, null: false
      t.text :content
    end
  end
end
