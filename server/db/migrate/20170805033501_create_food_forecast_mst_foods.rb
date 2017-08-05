class CreateFoodForecastMstFoods < ActiveRecord::Migration[5.1]
  def change
    create_table :food_forecast_mst_foods do |t|
      t.string :food_id, null: false
      t.string :name, null: false
      t.integer :classification, null: false, default: 0
      t.float :disposal, null: false, default: 0
      t.float :kcal, null: false, default: 0
      t.float :corrected_kcal, null: false, default: 0
    end

    add_index :food_forecast_mst_foods, :food_id, unique: true, name: "foods_food_id_index"
    add_index :food_forecast_mst_foods, :name, name: "foods_name_index"
    add_index :food_forecast_mst_foods, :classification, name: "foods_classification_index"
  end
end
