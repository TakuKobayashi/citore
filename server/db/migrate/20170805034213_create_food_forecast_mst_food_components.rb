class CreateFoodForecastMstFoodComponents < ActiveRecord::Migration[5.1]
  def change
    create_table :food_forecast_mst_food_components do |t|
      t.integer :mst_food_id, null: false
      t.integer :factor, null: false
      t.float :value, null: false, default: 0
    end
    add_index :food_forecast_mst_food_components, [:mst_food_id, :factor], name: "food_components_food_factor_index"
  end
end
