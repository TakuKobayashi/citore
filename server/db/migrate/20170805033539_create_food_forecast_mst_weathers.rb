class CreateFoodForecastMstWeathers < ActiveRecord::Migration[5.1]
  def change
    create_table :food_forecast_mst_weathers do |t|
      t.string :name, null: false
      t.integer :factor, null: false
      t.integer :inequality, null: false
      t.float :threshold, null: false, default: 0
    end

    add_index :food_forecast_mst_weathers, :factor, unique: true, name: "weather_factor_index"
  end
end
