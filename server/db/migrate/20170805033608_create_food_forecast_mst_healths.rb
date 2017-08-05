class CreateFoodForecastMstHealths < ActiveRecord::Migration[5.1]
  def change
    create_table :food_forecast_mst_healths do |t|
      t.string :name, null: false
      t.text :column
    end
  end
end
