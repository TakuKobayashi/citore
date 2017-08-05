class CreateFoodForecastFoodRecipes < ActiveRecord::Migration[5.1]
  def change
    create_table :food_forecast_food_recipes do |t|
      t.integer :mst_food_id, null: false
      t.float :weight, null: false, default: 1
      t.string :url, null: false
      t.text :content
    end
    add_index :food_forecast_food_recipes, :mst_food_id, name: "food_forecast_recipe_food_id_index"
  end
end
